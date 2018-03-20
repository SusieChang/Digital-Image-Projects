
/**************************************************************************************************
描述：这是一个压缩和解压缩图片程序。程序使用opencv,需配置相关软件，需在属性管理Debug|x64中配置：       
	1. 配置链接器的附加依赖项(opencv_world340d.lib)、
	2. VC++包含目录(安装目录\opencv\build\include\opencv和安装目录\opencv\build\include\opencv2)，
    3. VC++库目录(安装目录\opencv\build\x64\vc14\lib)。     
	4. 运行时缺少dll文件将vc14\bin\opencv_world340d.dll文件复制到C\Windows即可
	@ 测试时运行Debug|x64,改变测试文件只需改变main函数中的文件路径即可。
**************************************************************************************************/
#include <opencv2/opencv.hpp>
#include <iostream>
#include <fstream>
#include <opencv.hpp>
#include <cv.h> 
#include <vector>
#include <io.h>
#include "HTree.h"
#define MAX_NUM 256
using namespace std;
using namespace cv;


void zipped(char *infilepath, char *outfilepath) {
	IplImage *img = cvLoadImage(infilepath);
	int i, j;
	//如果图片路径错误，显示错误信息
	if (img == NULL) {
		cout << "wrong path of file" << endl;
		system("pause");
		return;
	}
	cout << "============图片已载入，正在压缩================" << endl;
	//step 表示每行的长度
	int step = img->widthStep / sizeof(ElemType);
	//size 表示图片总的像素个数
	int size_img = img->width*img->height*img->nChannels;
	int height = img->height;
	int width = img->width;
	//data 存储全部像素，是一个指向一维数组的指针
	ElemType* data = (ElemType *)img->imageData;
	ElemType* tmpdata = new ElemType[size_img];
	// channels 表示图像的通道个数,本程序可以测试彩色和灰度图片
	int channels = img->nChannels;
	ElemType tmpbuff;
	char buff[MAX_NUM] = "\0";
	//symbols用来统计每个字符出现的频数
	node* symbols = new node[MAX_NUM];
	//初始化symbols
	for (i = 0; i < MAX_NUM; i++) {
		symbols[i].ch = ElemType(i);
		symbols[i].weight = 0;
	}
	int index = 0;
	//遍历图像的每个像素点,统计每个字符出现的频率
	for (int i = 0; i < height; i++)
		for (int j = 0; j < width; j++)
			for (int k = 0; k < channels; k++) {
				ElemType pix_value = (ElemType)(img->imageData[i*step + j*channels + k]);
				tmpdata[index++] = pix_value;
				int n = (int)pix_value;
				symbols[n].weight++;			
	}
	//使用自定义比较函数，按权重(频率)从大到小排序，同时去掉频率为0的权重
	sort(symbols, symbols + MAX_NUM - 1, cmp);
	int kinds = 0;
	for (i = 0; i < MAX_NUM; i++) {
		if (symbols[i].weight == 0) break;
		kinds++;
	}
	//建哈夫曼树，编码
	HTree ht(kinds, symbols);
	delete[]symbols;
	ht.createHuffTree();
	ht.defineHuffCode();
	//写入文件生成压缩文件
	FILE* out;
	out = fopen(outfilepath,"wb");
	if (out != NULL) {
		// 图片信息
		fwrite((char *)&kinds, sizeof(int), 1, out);
		fwrite((char *)&height, sizeof(int), 1, out);
		fwrite((char *)&width, sizeof(int), 1, out);
		fwrite((char *)&channels, sizeof(int), 1, out);
		for (int i = 0; i < kinds; i++) {
			ht.print(i, out);
		}
		// 再次扫描整个图像的每个像素点，将对应哈夫曼编码存入文件
		for (j = 0; j < size_img; j++) {
			tmpbuff = tmpdata[j];
			for (int s = 0; s < kinds; s++) {
				if (ht.htree[s].ch == tmpbuff) {
					strcat(buff, ht.htree[s].code);
				}
			}
			while (strlen(buff) >= 8) {
				tmpbuff = chars_to_bits(buff, 8);
				fwrite((char *)&tmpbuff, sizeof(ElemType), 1, out);
				strcpy(buff, buff + 8);
			}
		}
		int reslen = strlen(buff);
		if (reslen > 0) {
			tmpbuff = chars_to_bits(buff, reslen);
			fwrite((char *)&tmpbuff, sizeof(ElemType), 1, out);
		}
	}
	fclose(out);
	CvSize imgsize;
	imgsize.height = img->height;
	imgsize.width = img->width;
	IplImage *src = cvCreateImage(imgsize, IPL_DEPTH_8U, channels);
	//将数组数据传给图像
	src->imageData = (char*)tmpdata;
	cvNamedWindow("原图", CV_WINDOW_AUTOSIZE);
	cvShowImage("原图", src);
	cvWaitKey(0);
	cvReleaseImage(&img);
	cout << "============图片已经压缩完毕====================" << endl;
};


void unzipped(char* infile_path, char* outfile_path) {
	FILE* ifs;
	ifs = fopen(infile_path,"rb");
	int size, kinds, height, width, channels, step, node_count, target,w;
	ElemType ch;
	char* tmpcode = new char[8];
	if (!ifs) {
		cout <<"wrong file path!";
		return;
	} 
	cout << "============文件已载入，正在解压================" << endl;
	//读入图片信息
	fread((char *)&kinds, sizeof(int),1,ifs);
	fread((char *)&height, sizeof(int),1,ifs);
	fread((char *)&width, sizeof(int),1,ifs);
	fread((char *)&channels, sizeof(int),1,ifs);
	node* symbols = new node[kinds];
	size = height*width*channels;
	ElemType* tmpdata = new ElemType[size];
	node_count = 2 * kinds - 1;
	// 读入编码表（字符和对应权重）
	for (int i = 0; i < kinds; i++) {
		fread((char *)&ch, sizeof(ElemType),1,ifs);
		fread((char *)&w, sizeof(int),1,ifs);
		symbols[i].ch = ch;
		symbols[i].weight = w;
	}
	//建哈夫曼树
	HTree ht(kinds, symbols);
	delete[]symbols;
	ht.createHuffTree();
	target = node_count - 1;
	int index = 0;
	while(index < size) {
		fread((char *)&ch, sizeof(ElemType),1,ifs);
		for (int i = 0; i < 8; i++, ch<<=1) {
			(ch & 128) ? target = ht.htree[target].right:target = ht.htree[target].left;
			if (target < kinds)
			{
				if (index >= size) break;
				tmpdata[index++] = ht.htree[target].ch;
				target = node_count - 1;  
			}
		}
	}

	//定义新空图像
	IplImage *src = cvCreateImage(CvSize(width,height), IPL_DEPTH_8U, channels);
	//将数组数据传给图像
	src->imageData = (char*)tmpdata;
	cvNamedWindow("解压后的图像", CV_WINDOW_AUTOSIZE);
	cvShowImage("解压后的图像", src);
	cout << "============图片已经解压完毕====================" << endl;
	cvWaitKey(0);
	cvSaveImage(outfile_path, src);
	//cvDestroyAllWindows();
	fclose(ifs);	
}



// 计算信噪比SNR
double compute_snr(char* img1_path, char* img2_path) {
	IplImage *img1 = cvLoadImage(img1_path);
	IplImage *img2 = cvLoadImage(img2_path);
	int len1 = img1->width*img1->height*img1->nChannels;
	int len2 = img2->width*img2->height*img2->nChannels;
	if (len1 != len2) {
		cout << "the size of picture is different. wrong input!";
		return 0;
	}
	double num = 0;
	double den = 0;
	double snr = 0;
	for (int i = 0; i < len1; i++) {
		int data1 = (int)(ElemType)img1->imageData[i];
		int data2 = (int)(ElemType)img2->imageData[i];
		num += data1*data1;
		den += (data1 - data2)*(data1 - data2);
	}
	snr = (double)num / (double)(den);
	return 10 * log10(snr);
};

// 计算峰值信噪比
double compute_psnr(char* img1_path, char* img2_path)
{
	Mat s1;
	Mat I1 = imread(img1_path);
	Mat I2 = imread(img2_path);
	absdiff(I1, I2, s1);       
	s1.convertTo(s1, CV_32F);  
	s1 = s1.mul(s1);          
	Scalar s = sum(s1);       
	double sse = s.val[0] + s.val[1] + s.val[2]; 	
	double  mse = sse / (double)(I1.channels() * I1.total());
	double psnr = 20.0*log10(255 / sqrt(mse));
	return psnr;
}

//计算压缩比
double computeCompressRatio(char* file1_path, char* file2_path) {
	FILE* file1 = fopen(file1_path, "rb");
	FILE* file2 = fopen(file2_path, "rb");
	if (!file1 || !file2) {
		cout << "can't open the file!" << endl;
		return 0;
	}
	int size1 = filelength(fileno(file1));
	int size2 = filelength(fileno(file2));
	fclose(file1);
	fclose(file2);
	return (double)size2 / (double)size1;
};

//给压缩文件命名
char* nameZippedFile(char* img_name) {
	int n = strlen(img_name);
	int i = 0;
	char* tmp = new char[n];
	for (i = 0; i < n; i++) {
		if (img_name[i] == '.') {
			break;
		}
	}
	char* name = new char[i];
	strncpy(name, img_name, i);
	name[i] = '\0';
	name = strcat(name, ".txt");
	return name;
};
// 拼接char*类型字符串
char* jointStr(char* str1, char* str2) {
	char* str = new char[MAX_NUM];
	strcpy(str, str1);
	strcat(str, str2);
	return str;
};

int main() {
	//可更改
	char* img_name = "lenna.bmp";	
	
	//压缩解压缩操作
	char* image_file = "images\\";
	char* zipped_file = "zipped\\";
	char* unzipped_file = "unzipped\\";
	char* image_path = jointStr(image_file, img_name);
	char* zipped_path = jointStr(zipped_file, nameZippedFile(img_name));
	char* unzipped_path = jointStr(unzipped_file, img_name);
	zipped(image_path,zipped_path);
	unzipped(zipped_path, unzipped_path);

	//ofstream out("evalute_indexs.txt", ios::app);//ios::app表示在原文件末尾追加
	//if (!out) {
	//	cout << "Open the file failure...\n";
	//	return 0;
	//}
	//out << "Name: "<<img_name << endl;
	//out << "SNR: " << compute_snr(image_path, unzipped_path) << endl;
	//out << "PSNR: " << compute_psnr(image_path, unzipped_path) << endl;
	//out << "Compression Ratio: " << computeCompressRatio(image_path, zipped_path) << endl;
	//out.close();
	cout << "Name: " << img_name << endl;
	cout << "SNR: " << compute_snr(image_path, unzipped_path) << endl;
	cout << "PSNR: " << compute_psnr(image_path, unzipped_path) << endl;
	cout << "Compression Ratio: " << computeCompressRatio(image_path, zipped_path) << endl;
	system("pause");
	return 0;
}
#pragma once
#include <system_error>
#include <iostream>
#include <fstream>
#include <string>
#include <cv.h>
using namespace std;
const int MAX_NUM = 256;	   //定义字符种类的最大值
typedef uchar ElemType;//定义字符类型
//定义一个树节点
typedef struct HuffNode {	   
	ElemType ch;
	char* code;
	int weight;
	int parent, left, right;
} HuffNode, *HuffTree;

//定义一个结构存储字符和对应权重
typedef struct node {			
	ElemType ch;
	int weight;
} node;

//定义一个比较函数，根据权重由大到小排序
bool cmp(struct node a, struct node b) 
{
	if (a.weight > b.weight)
	{
		return true;
	}
	return false;
}

//定义一颗哈夫曼树
class HTree {
public:
	HuffTree htree;
	int kinds;
	HTree(int,node*);
	HTree() {};
	~HTree() {};
	void selectMin2(int &left, int &right, int k);
	void createHuffTree();
	void defineHuffCode();
	void print(int, FILE*);
};

// 初始化哈夫曼树
HTree::HTree(int k,node* symbols) { 
	kinds = k; 	
	int node_count = 2 * k - 1; 
	htree = new HuffNode[node_count]; 
	for (int i = 0; i < node_count; i++) {
		if (i < kinds) {
			htree[i].ch = symbols[i].ch;
			htree[i].weight = symbols[i].weight;
		}
		htree[i].parent = -1;
	}
};

// 从节点中选择最小的两个
void HTree::selectMin2(int& left, int& right, int k) {
	int min1 = INT_MAX, min2 = INT_MAX;
	int tmp = 0;
	for (int i = 0; i < k; i++) {
		if (htree[i].parent == -1 && htree[i].weight < min1) {
			min1 = htree[i].weight;
			left = i;
			tmp = i;
		}
	}
		htree[left].parent = 1;
	for (int i = 0; i < k; i++) {
		if (htree[i].parent == -1 && htree[i].weight < min2) {
			min2 = htree[i].weight;
			right = i;
		}
	}
};
//根据编码表创建哈夫曼树
void HTree::createHuffTree() {
	int left, right;
	for (int i = kinds; i < kinds * 2 - 1; i++) {
		selectMin2(left, right, i);
		htree[left].parent = htree[right].parent = i;
		htree[i].right = right;
		htree[i].left = left;
		htree[i].weight = htree[left].weight + htree[right].weight;
	}
};
//编码
void HTree::defineHuffCode() {
	int cur, next, idx;
	char* tmp = new char[MAX_NUM];
	tmp[MAX_NUM - 1] = '\0';
	for (int i = 0; i < kinds; i++) {
		idx = MAX_NUM - 1;
		for (cur = i, next = htree[i].parent; next != -1;
			cur = next, next = htree[next].parent) {
			if (htree[next].left == cur) {
				tmp[--idx] = '0';
			}
			else {
				tmp[--idx] = '1';
			}
		}
		htree[i].code = new char[MAX_NUM - idx];
		strcpy(htree[i].code, &tmp[idx]);
	}
	delete[] tmp;
};

// 打印编码表
void HTree::print(int k, FILE* f) {
	if (k < kinds) {
		fwrite((char *)&htree[k].ch, sizeof(ElemType),1,f);
		fwrite((char *)&htree[k].weight, sizeof(int),1,f);
	}
	else {
		cout << "out of range.";
	}

};

ElemType chars_to_bits(const char *chs,int len)
{	
	ElemType bits = '\0';
	for (int i = 0; i < len; ++i) {	
		bits <<= 1;
		if (chs[i] == '1')
			bits |= 1;
	}
	bits <<= 8 - len;
	return bits;
}
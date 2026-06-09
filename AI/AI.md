# AI



* **ETL**: 将参考资料加载到向量数据库
  * E: 抽取.从不同的源中抽取文本
  * T: 转换.将文本切分转换成小块
  * L: 加载.将转换后的文本块存储到向量数据库,如redis
* **RAG(Retrieval-Augmented Generation)**: 把资料切成小块、向量化存进向量库,提问时先根据Prompt检索相关片段,再拼进 Prompt 给模型
# Miniprogram



# 官网



* [指南](https://developers.weixin.qq.com/miniprogram/dev/framework/)



# 结构



## pages



* pages中每个文件夹都是一个页面,每个页面又通常包括4个文件



### index.js



* 页面逻辑文件,语法类似于Vue,但也有很多不同,具体参考官方文档



### index.json



* 静态数据
* usingComponents: 组件引用,以key-value的形式将项目中的通用组件引入当前页面中,在页面中可直接使用key当作标签

```json
{
  "usingComponents": {
      // key为在wxml中使用时的标签,value为组件路径
      "c-tree": "/components/tree/index"
  }
}
```



### index.wxml



* 页面文件,类似于Vue中的vue文件,语法也类似



### index.wxss



* CSS文件



## utils



* 工具类文件夹



## 其他文件



### app.json



#### pages



* 数组,小程序中所有的页面,默认加载数组第一个页面



# Component



* [文档](https://developers.weixin.qq.com/miniprogram/dev/reference/api/Component.html)
* 组件,类似于vue中的组件,nginx中的include等
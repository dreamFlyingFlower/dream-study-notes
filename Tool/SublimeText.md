# SublimeText



# 移动插件目录



* 若使用安装程序安装,如下步骤可不将插件安装在C盘

  * 打开SublimeText4->Preferences->Browse Packages,此时打开的是Packages文件夹,直接将上2层的SublimeText目录删除

  * 在原SublimeText安装目录下新建Data目录,必须是Data,否则识别不到
  * 关闭Sublime Text,打开之后的缓存和插件都将安装在Data中



# 设置



* Preferences->Settings

  ```json
  {
      "font_size": 12,
      "font_face": "Comic Sans MS",
  }
  ```



# 快捷键



* Preferences->Key Bindings

  ```json
  [
      // 删除改为ctrl+d.复制到文件中时注释要删除
  	{ "keys": ["ctrl+d"], "command": "run_macro_file", "args": {"file": "res://Packages/Default/Delete Line.sublime-macro"} },
  	{ "keys": ["ctrl+shift+k"], "command": "find_under_expand" },
  ]
  ```
  



# 插件



* ChineseLocalizations:中文语言包,让 Sublime Text 界面显示为中文

* ConvertToUTF8:支持将其他编码类型的文件转换为UTF8打开

* BracketHighlighter:括号高亮
* ColorPicker:可以在编辑器中方便的选择颜色
* AutoFileName:可以实现自动补全文件名的功能,从而可以提高代码编写和编辑的效率
* Emmet:代码自动补全,快捷键为Tab
* Pretty Json:json格式化,需要自行设置快捷键,在快捷键设置里添加`{"keys": ["ctrl+alt+j"], "command": "pretty_json"}`
* FileDiffs:文件比较
* Alignment:自动对齐代码
* SideBar Enhancements:侧边栏扩展


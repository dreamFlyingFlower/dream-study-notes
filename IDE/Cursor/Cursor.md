# 安装Cursor v0.44.11



> 如果你是 Cursor v0.44.11 及以下版本,可以跳过步骤一,否则请重新安装旧版本



## 卸载0.45及以上版本cursor



打开 Windows设置 -> 应用 -> 安装的应用 -> 搜索cursor -> 卸载

![img](https://pic3.zhimg.com/v2-16bfbc50ac9fb37a89e93c6372a9f116_1440w.jpg)



## 删除用户设置和缓存



删除Windows以下位置的文件夹：

```bash
C:\Users\{你的用户名}\AppData\Roaming\Cursor
```



## 重新下载cursor



点击下载 **v0.44.11** (2025-01-03) - 最稳定版本：[WINDOWS安装包](https://link.zhihu.com/?target=https%3A//downloader.cursor.sh/builds/250103fqxdt5u9z/windows/nsis/x64)



# 重置试用期和使用次数



## 删除账户



打开Cursor设置 -> General -> Account -> 点击Manage

![img](https://pic3.zhimg.com/v2-1a0a59231b5c85308b181aa481a5379e_1440w.jpg)

在Settings中Account -> Advanced -> Delete Account,点击删除账户

![img](https://pic3.zhimg.com/v2-0d75622706591f35734d931350140304_1440w.jpg)



## 打开PowerShell



Windows底栏 开始 -> 搜索 -> 输入power shell -> **以管理员身份运行**

![img](https://picx.zhimg.com/v2-5e343f2636605c2da47a83503b5ebebf_1440w.jpg)



## 输入重置脚本



在打开的终端中输入以下指令：

```bash
irm https://aizaozao.com/accelerate.php/https://raw.githubusercontent.com/yuaotian/go-cursor-help/refs/heads/master/scripts/run/cursor_win_id_modifier.ps1 | iex
```

*来源：[GitHub](https://zhida.zhihu.com/search?content_id=254170561&content_type=Article&match_order=1&q=GitHub&zhida_source=entity) yuaotian大佬开源 [yuaotian/go-cursor-help](https://link.zhihu.com/?target=https%3A//github.com/yuaotian/go-cursor-help)*

或者将该脚本下载到本地,右键使用管理员权限执行该脚本



## 禁用Cursor自动更新



运行重置脚本时,最后会询问是否禁用自动更新,输入1

![img](https://pic2.zhimg.com/v2-4977b39ecf126eb02600e94779686971_1440w.jpg)

> upd：**增加了2.1“运行脚本前要先删除账户”,执行完脚本我的试用期和使用次数都重置了,如果你没有成功可以继续执行步骤三**



# 重置模型使用次数



> Cursor Pro版试用期间每天仅限试用50次高级请求（claude-3.5-sonnet, gpt-4o等）



## 下载扩展插件



点击下载：[cursor-fake-machine](https://link.zhihu.com/?target=https%3A//github.com/bestK/cursor-fake-machine/releases/download/v0.0.2/cursor-fake-machine-0.0.2.vsix)

*来源：GitHub bestK大佬开源 [bestK/cursor-fake-machine](https://link.zhihu.com/?target=https%3A//github.com/bestK/cursor-fake-machine%3Ftab%3Dreadme-ov-file)*



## 将插件复制进扩展



复制下载的文件,打开Cursor的扩展并粘贴

![img](https://picx.zhimg.com/v2-63fa4db2f1ee0ee0682b16c1a0b13595_1440w.jpg)

或者直接将文件拖入扩展

![img](https://pica.zhimg.com/v2-a7ace8f5374da1aa0a4bdd05113b44cc_1440w.jpg)



## 删除账户



打开Cursor设置 -> General -> Account -> 点击Manage

![img](https://pic3.zhimg.com/v2-1a0a59231b5c85308b181aa481a5379e_1440w.jpg)

在Settings中Account -> Advanced -> Delete Account,点击删除账户

![img](https://pic3.zhimg.com/v2-0d75622706591f35734d931350140304_1440w.jpg)



## 运行 Fake Cursor: Fake Machine



返回Cursor,Ctrl + shift + P打开输入框 -> 输入fake,点击运行Fake Cursor: Fake Machine

![img](https://pic1.zhimg.com/v2-97b2d48f1c5c0bca5652c180f5291a1c_1440w.jpg)

接着提示修改成功！



## 如法炮制



如果一天使用premium模型50次达到上限了,可以重复 步骤3.3~3.4 重置模型使用次数



# 查看结果



打开步骤3.3的Manage,或者直接点击 [https://www.cursor.com/cn/settings](https://link.zhihu.com/?target=https%3A//www.cursor.com/cn/settings)

![img](https://pic1.zhimg.com/v2-9694a965b4859fec47c5a8bc193ba786_1440w.jpg)

登录自己的Cursor账号,可以看到**试用时间和模型使用次数**都被重置了

> 如果没有重置成功,可以调换顺序试一下,先执行步骤三再执行步骤二
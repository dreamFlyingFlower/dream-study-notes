# Vue2



# 标签



## v-if,v-show



* `v-if`为false时,相当于visible,页面不会渲染,也不会有任何元素;`v-show`为false时,相当于加了`display:none`,页面仍然有元素
* `v-if`可以使用在template上,去除使用`div`留下的影响;`v-show`不能使用在tempalte上
* `v-if`适用于不频繁渲染的元素



## v-model



* 当该标签直接绑定属性时,绑定的是`input`事件;如果是`v-model.lazy`,则绑定的是`change`事件



# Computed



* 计算属性,定义在当前对象里的属性不能定义在data中
* 计算属性会有缓存,适用于大量重复操作.数据发生变化时才重新计算,如果里面的属性没发生改变,则不会执行逻辑



# Watch



* 监听器.监听定义在data里的数据.同时接收2个参数:新值,旧值

* 默认侦听只会监听对象本身,若需要监听对象里的对象,使用`deep:true`

  ```vue
  <script>
  watch:{
  	version:{
  		// 深度侦听
  		deep:true,
  		// 立即执行,当页面初始化时,值没有发生改变,仍然会执行一次
  		immediate: true,
  		handler:function(newValue,oldValue){
  
  		}
  	}
  	// 默认侦听
  	version(newValue,oldValue){
  	
  	}
  }
  </script>
  ```

* 在其他地方调用wath

  ```vue
  created(){
  	// 有返回值
  	const unwatch = this.$watch('data中的属性',(newValue,OldValue)=>{
  
  	})
  	// 调用返回值可取消监听,但是不能取消写在wath里的侦听
  	unwatch();
  }
  ```

  



# 特殊对象



## this



* 当在`methods`中定义方法时,若该方法定义为箭头函数,则该方法中的`this`默认指向window.其他定义方式则指向Vue对象



## event



* 在`template`中调用方法时,会默认传递`event`参数,如果有多个参数,需要显示的传递`$event`

  ```vue
  <template>
  	<button v-on:click="handle('ok', $event)"></button>
  </template>
  
  <script>
  	methods:{
      	<!-- event接收$event -->
      	handle(status,event){}
      }
  </script>
  ```



# 翻页


# BeanFactory



```java
package org.springframework.beans.factory;

/**
 * The root interface for accessing a Spring bean container
 */
public interface BeanFactory {

	/**
	 * Used to dereference a {@link FactoryBean} instance and distinguish it from
	 * beans <i>created</i> by the FactoryBean. For example, if the bean named
	 * {@code myJndiObject} is a FactoryBean, getting {@code &myJndiObject}
	 * will return the factory, not the instance returned by the factory.
	 */
	String FACTORY_BEAN_PREFIX = "&";


	/**
	 * Return an instance, which may be shared or independent, of the specified bean.
	 * <p>This method allows a Spring BeanFactory to be used as a replacement for the
	 * Singleton or Prototype design pattern. Callers may retain references to
	 * returned objects in the case of Singleton beans.
	 * <p>Translates aliases back to the corresponding canonical bean name.
	 * <p>Will ask the parent factory if the bean cannot be found in this factory instance.
	 * @param name the name of the bean to retrieve
	 * @return an instance of the bean
	 */
	Object getBean(String name) throws BeansException;

	/**
	 * Return an instance, which may be shared or independent, of the specified bean.
	 * <p>Behaves the same as {@link #getBean(String)}, but provides a measure of type
	 * safety by throwing a BeanNotOfRequiredTypeException if the bean is not of the
	 * required type. This means that ClassCastException can't be thrown on casting
	 * the result correctly, as can happen with {@link #getBean(String)}.
	 * <p>Translates aliases back to the corresponding canonical bean name.
	 * <p>Will ask the parent factory if the bean cannot be found in this factory instance.
	 * @param name the name of the bean to retrieve
	 * @param requiredType type the bean must match; can be an interface or superclass
	 * @return an instance of the bean
	 */
	<T> T getBean(String name, Class<T> requiredType) throws BeansException;

	/**
	 * Return an instance, which may be shared or independent, of the specified bean.
	 * <p>Allows for specifying explicit constructor arguments / factory method arguments,
	 * overriding the specified default arguments (if any) in the bean definition.
	 * @param name the name of the bean to retrieve
	 * @param args arguments to use when creating a bean instance using explicit arguments
	 * (only applied when creating a new instance as opposed to retrieving an existing one)
	 * @return an instance of the bean
	 */
	Object getBean(String name, Object... args) throws BeansException;

	/**
	 * Return the bean instance that uniquely matches the given object type, if any.
	 * <p>This method goes into {@link ListableBeanFactory} by-type lookup territory
	 * but may also be translated into a conventional by-name lookup based on the name
	 * of the given type. For more extensive retrieval operations across sets of beans,
	 * use {@link ListableBeanFactory} and/or {@link BeanFactoryUtils}.
	 * @param requiredType type the bean must match; can be an interface or superclass
	 * @return an instance of the single bean matching the required type
	 * @see ListableBeanFactory
	 */
	<T> T getBean(Class<T> requiredType) throws BeansException;

	/**
	 * Return an instance, which may be shared or independent, of the specified bean.
	 * <p>Allows for specifying explicit constructor arguments / factory method arguments,
	 * overriding the specified default arguments (if any) in the bean definition.
	 * <p>This method goes into {@link ListableBeanFactory} by-type lookup territory
	 * but may also be translated into a conventional by-name lookup based on the name
	 * of the given type. For more extensive retrieval operations across sets of beans,
	 * use {@link ListableBeanFactory} and/or {@link BeanFactoryUtils}.
	 * @param requiredType type the bean must match; can be an interface or superclass
	 * @param args arguments to use when creating a bean instance using explicit arguments
	 * (only applied when creating a new instance as opposed to retrieving an existing one)
	 * @return an instance of the bean
	 */
	<T> T getBean(Class<T> requiredType, Object... args) throws BeansException;

	/**
	 * Return a provider for the specified bean, allowing for lazy on-demand retrieval
	 * of instances, including availability and uniqueness options.
	 * @param requiredType type the bean must match; can be an interface or superclass
	 * @return a corresponding provider handle
	 * @see #getBeanProvider(ResolvableType)
	 */
	<T> ObjectProvider<T> getBeanProvider(Class<T> requiredType);

	/**
	 * Return a provider for the specified bean, allowing for lazy on-demand retrieval
	 * of instances, including availability and uniqueness options.
	 * @param requiredType type the bean must match; can be a generic type declaration.
	 * Note that collection types are not supported here, in contrast to reflective
	 * injection points. For programmatically retrieving a list of beans matching a
	 * specific type, specify the actual bean type as an argument here and subsequently
	 * use {@link ObjectProvider#orderedStream()} or its lazy streaming/iteration options.
	 * @return a corresponding provider handle
	 * @see ObjectProvider#iterator()
	 * @see ObjectProvider#stream()
	 * @see ObjectProvider#orderedStream()
	 */
	<T> ObjectProvider<T> getBeanProvider(ResolvableType requiredType);

	/**
	 * Does this bean factory contain a bean definition or externally registered singleton
	 * instance with the given name?
	 * <p>If the given name is an alias, it will be translated back to the corresponding
	 * canonical bean name.
	 * <p>If this factory is hierarchical, will ask any parent factory if the bean cannot
	 * be found in this factory instance.
	 * <p>If a bean definition or singleton instance matching the given name is found,
	 * this method will return {@code true} whether the named bean definition is concrete
	 * or abstract, lazy or eager, in scope or not. Therefore, note that a {@code true}
	 * return value from this method does not necessarily indicate that {@link #getBean}
	 * will be able to obtain an instance for the same name.
	 * @param name the name of the bean to query
	 * @return whether a bean with the given name is present
	 */
	boolean containsBean(String name);

	/**
	 * Is this bean a shared singleton? That is, will {@link #getBean} always
	 * return the same instance?
	 * <p>Note: This method returning {@code false} does not clearly indicate
	 * independent instances. It indicates non-singleton instances, which may correspond
	 * to a scoped bean as well. Use the {@link #isPrototype} operation to explicitly
	 * check for independent instances.
	 * <p>Translates aliases back to the corresponding canonical bean name.
	 * <p>Will ask the parent factory if the bean cannot be found in this factory instance.
	 * @param name the name of the bean to query
	 * @return whether this bean corresponds to a singleton instance
	 * @see #getBean
	 * @see #isPrototype
	 */
	boolean isSingleton(String name) throws NoSuchBeanDefinitionException;

	/**
	 * Is this bean a prototype? That is, will {@link #getBean} always return
	 * independent instances?
	 * <p>Note: This method returning {@code false} does not clearly indicate
	 * a singleton object. It indicates non-independent instances, which may correspond
	 * to a scoped bean as well. Use the {@link #isSingleton} operation to explicitly
	 * check for a shared singleton instance.
	 * <p>Translates aliases back to the corresponding canonical bean name.
	 * <p>Will ask the parent factory if the bean cannot be found in this factory instance.
	 * @param name the name of the bean to query
	 * @return whether this bean will always deliver independent instances
	 */
	boolean isPrototype(String name) throws NoSuchBeanDefinitionException;

	/**
	 * Check whether the bean with the given name matches the specified type.
	 * More specifically, check whether a {@link #getBean} call for the given name
	 * would return an object that is assignable to the specified target type.
	 * <p>Translates aliases back to the corresponding canonical bean name.
	 * <p>Will ask the parent factory if the bean cannot be found in this factory instance.
	 * @param name the name of the bean to query
	 * @param typeToMatch the type to match against (as a {@code ResolvableType})
	 * @return {@code true} if the bean type matches,
	 * {@code false} if it doesn't match or cannot be determined yet
	 */
	boolean isTypeMatch(String name, ResolvableType typeToMatch) throws NoSuchBeanDefinitionException;

	/**
	 * Check whether the bean with the given name matches the specified type.
	 * More specifically, check whether a {@link #getBean} call for the given name
	 * would return an object that is assignable to the specified target type.
	 * <p>Translates aliases back to the corresponding canonical bean name.
	 * <p>Will ask the parent factory if the bean cannot be found in this factory instance.
	 * @param name the name of the bean to query
	 * @param typeToMatch the type to match against (as a {@code Class})
	 * @return {@code true} if the bean type matches,
	 * {@code false} if it doesn't match or cannot be determined yet
	 */
	boolean isTypeMatch(String name, Class<?> typeToMatch) throws NoSuchBeanDefinitionException;

	/**
	 * Determine the type of the bean with the given name. More specifically,
	 * determine the type of object that {@link #getBean} would return for the given name.
	 * <p>For a {@link FactoryBean}, return the type of object that the FactoryBean creates,
	 * as exposed by {@link FactoryBean#getObjectType()}. This may lead to the initialization
	 * of a previously uninitialized {@code FactoryBean} (see {@link #getType(String, boolean)}).
	 * <p>Translates aliases back to the corresponding canonical bean name.
	 * <p>Will ask the parent factory if the bean cannot be found in this factory instance.
	 * @param name the name of the bean to query
	 * @return the type of the bean, or {@code null} if not determinable
	 */
	@Nullable
	Class<?> getType(String name) throws NoSuchBeanDefinitionException;

	/**
	 * Determine the type of the bean with the given name. More specifically,
	 * determine the type of object that {@link #getBean} would return for the given name.
	 * <p>For a {@link FactoryBean}, return the type of object that the FactoryBean creates,
	 * as exposed by {@link FactoryBean#getObjectType()}. Depending on the
	 * {@code allowFactoryBeanInit} flag, this may lead to the initialization of a previously
	 * uninitialized {@code FactoryBean} if no early type information is available.
	 * <p>Translates aliases back to the corresponding canonical bean name.
	 * <p>Will ask the parent factory if the bean cannot be found in this factory instance.
	 * @param name the name of the bean to query
	 * @param allowFactoryBeanInit whether a {@code FactoryBean} may get initialized
	 * just for the purpose of determining its object type
	 * @return the type of the bean, or {@code null} if not determinable
	 */
	@Nullable
	Class<?> getType(String name, boolean allowFactoryBeanInit) throws NoSuchBeanDefinitionException;

	/**
	 * Return the aliases for the given bean name, if any.
	 * <p>All of those aliases point to the same bean when used in a {@link #getBean} call.
	 * <p>If the given name is an alias, the corresponding original bean name
	 * and other aliases (if any) will be returned, with the original bean name
	 * being the first element in the array.
	 * <p>Will ask the parent factory if the bean cannot be found in this factory instance.
	 * @param name the bean name to check for aliases
	 * @return the aliases, or an empty array if none
	 * @see #getBean
	 */
	String[] getAliases(String name);
}
```



# BeanDefinition



```java
package org.springframework.beans.factory.config;

/**
 * Bean对象信息描述,定义接口
 *
 * @see ConfigurableListableBeanFactory#getBeanDefinition
 * @see org.springframework.beans.factory.support.RootBeanDefinition
 * @see org.springframework.beans.factory.support.ChildBeanDefinition
 */
public interface BeanDefinition extends AttributeAccessor, BeanMetadataElement {

	/**
	 * 作用范围描述:单例
	 * @see #setScope
	 * @see ConfigurableBeanFactory#SCOPE_SINGLETON
	 */
	String SCOPE_SINGLETON = ConfigurableBeanFactory.SCOPE_SINGLETON;

	/**
	 * 作用范围描述:原型
	 * @see #setScope
	 * @see ConfigurableBeanFactory#SCOPE_PROTOTYPE
	 */
	String SCOPE_PROTOTYPE = ConfigurableBeanFactory.SCOPE_PROTOTYPE;


	/**
	 * Bean的角色,主要标识Bean是那个角色用的.当前角色为应用中的主要构成部分,通常是用户定义的对象
	 */
	int ROLE_APPLICATION = 0;

	/**
	 * Bean的角色,主要标识Bean是那个角色用的.当前角色主要为大的配置准备,通常来自于外部
	 */
	int ROLE_SUPPORT = 1;

	/**
	 * Bean的角色,主要标识Bean是那个角色用的.当前角色为后台基础对象,主要为容器中的Bean
	 */
	int ROLE_INFRASTRUCTURE = 2;

	/**
	 * Set the name of the parent definition of this bean definition, if any.
	 */
	void setParentName(@Nullable String parentName);

	/**
	 * Return the name of the parent definition of this bean definition, if any.
	 */
	@Nullable
	String getParentName();

	/**
	 * Specify the bean class name of this bean definition.
	 * <p>The class name can be modified during bean factory post-processing,
	 * typically replacing the original class name with a parsed variant of it.
	 * @see #setParentName
	 * @see #setFactoryBeanName
	 * @see #setFactoryMethodName
	 */
	void setBeanClassName(@Nullable String beanClassName);

	/**
	 * Return the current bean class name of this bean definition.
	 * <p>Note that this does not have to be the actual class name used at runtime, in
	 * case of a child definition overriding/inheriting the class name from its parent.
	 * Also, this may just be the class that a factory method is called on, or it may
	 * even be empty in case of a factory bean reference that a method is called on.
	 * Hence, do <i>not</i> consider this to be the definitive bean type at runtime but
	 * rather only use it for parsing purposes at the individual bean definition level.
	 * @see #getParentName()
	 * @see #getFactoryBeanName()
	 * @see #getFactoryMethodName()
	 */
	@Nullable
	String getBeanClassName();

	/**
	 * Override the target scope of this bean, specifying a new scope name.
	 * @see #SCOPE_SINGLETON
	 * @see #SCOPE_PROTOTYPE
	 */
	void setScope(@Nullable String scope);

	/**
	 * Return the name of the current target scope for this bean,
	 * or {@code null} if not known yet.
	 */
	@Nullable
	String getScope();

	/**
	 * Set whether this bean should be lazily initialized.
	 * <p>If {@code false}, the bean will get instantiated on startup by bean
	 * factories that perform eager initialization of singletons.
	 */
	void setLazyInit(boolean lazyInit);

	/**
	 * Return whether this bean should be lazily initialized, i.e. not
	 * eagerly instantiated on startup. Only applicable to a singleton bean.
	 */
	boolean isLazyInit();

	/**
	 * Set the names of the beans that this bean depends on being initialized.
	 * The bean factory will guarantee that these beans get initialized first.
	 */
	void setDependsOn(@Nullable String... dependsOn);

	/**
	 * Return the bean names that this bean depends on.
	 */
	@Nullable
	String[] getDependsOn();

	/**
	 * Set whether this bean is a candidate for getting autowired into some other bean.
	 * <p>Note that this flag is designed to only affect type-based autowiring.
	 * It does not affect explicit references by name, which will get resolved even
	 * if the specified bean is not marked as an autowire candidate. As a consequence,
	 * autowiring by name will nevertheless inject a bean if the name matches.
	 */
	void setAutowireCandidate(boolean autowireCandidate);

	/**
	 * Return whether this bean is a candidate for getting autowired into some other bean.
	 */
	boolean isAutowireCandidate();

	/**
	 * Set whether this bean is a primary autowire candidate.
	 * <p>If this value is {@code true} for exactly one bean among multiple
	 * matching candidates, it will serve as a tie-breaker.
	 */
	void setPrimary(boolean primary);

	/**
	 * Return whether this bean is a primary autowire candidate.
	 */
	boolean isPrimary();

	/**
	 * Specify the factory bean to use, if any.
	 * This the name of the bean to call the specified factory method on.
	 * @see #setFactoryMethodName
	 */
	void setFactoryBeanName(@Nullable String factoryBeanName);

	/**
	 * Return the factory bean name, if any.
	 */
	@Nullable
	String getFactoryBeanName();

	/**
	 * Specify a factory method, if any. This method will be invoked with
	 * constructor arguments, or with no arguments if none are specified.
	 * The method will be invoked on the specified factory bean, if any,
	 * or otherwise as a static method on the local bean class.
	 * @see #setFactoryBeanName
	 * @see #setBeanClassName
	 */
	void setFactoryMethodName(@Nullable String factoryMethodName);

	/**
	 * Return a factory method, if any.
	 */
	@Nullable
	String getFactoryMethodName();

	/**
	 * Return the constructor argument values for this bean.
	 * <p>The returned instance can be modified during bean factory post-processing.
	 * @return the ConstructorArgumentValues object (never {@code null})
	 */
	ConstructorArgumentValues getConstructorArgumentValues();

	/**
	 * Return if there are constructor argument values defined for this bean.
	 */
	default boolean hasConstructorArgumentValues() {
		return !getConstructorArgumentValues().isEmpty();
	}

	/**
	 * Return the property values to be applied to a new instance of the bean.
	 * <p>The returned instance can be modified during bean factory post-processing.
	 * @return the MutablePropertyValues object (never {@code null})
	 */
	MutablePropertyValues getPropertyValues();

	/**
	 * Return if there are property values defined for this bean.
	 */
	default boolean hasPropertyValues() {
		return !getPropertyValues().isEmpty();
	}

	/**
	 * Set the name of the initializer method.
	 */
	void setInitMethodName(@Nullable String initMethodName);

	/**
	 * Return the name of the initializer method.
	 */
	@Nullable
	String getInitMethodName();

	/**
	 * Set the name of the destroy method.
	 */
	void setDestroyMethodName(@Nullable String destroyMethodName);

	/**
	 * Return the name of the destroy method.
	 */
	@Nullable
	String getDestroyMethodName();

	/**
	 * Set the role hint for this {@code BeanDefinition}. The role hint
	 * provides the frameworks as well as tools an indication of
	 * the role and importance of a particular {@code BeanDefinition}.
	 * @see #ROLE_APPLICATION
	 * @see #ROLE_SUPPORT
	 * @see #ROLE_INFRASTRUCTURE
	 */
	void setRole(int role);

	/**
	 * Get the role hint for this {@code BeanDefinition}. The role hint
	 * provides the frameworks as well as tools an indication of
	 * the role and importance of a particular {@code BeanDefinition}.
	 * @see #ROLE_APPLICATION
	 * @see #ROLE_SUPPORT
	 * @see #ROLE_INFRASTRUCTURE
	 */
	int getRole();

	/**
	 * Set a human-readable description of this bean definition.
	 */
	void setDescription(@Nullable String description);

	/**
	 * Return a human-readable description of this bean definition.
	 */
	@Nullable
	String getDescription();

	/**
	 * Return a resolvable type for this bean definition,
	 * based on the bean class or other specific metadata.
	 * <p>This is typically fully resolved on a runtime-merged bean definition
	 * but not necessarily on a configuration-time definition instance.
	 * @return the resolvable type (potentially {@link ResolvableType#NONE})
	 * @see ConfigurableBeanFactory#getMergedBeanDefinition
	 */
	ResolvableType getResolvableType();

	/**
	 * Return whether this a <b>Singleton</b>, with a single, shared instance
	 * returned on all calls.
	 * @see #SCOPE_SINGLETON
	 */
	boolean isSingleton();

	/**
	 * Return whether this a <b>Prototype</b>, with an independent instance
	 * returned for each call.
	 * @see #SCOPE_PROTOTYPE
	 */
	boolean isPrototype();

	/**
	 * Return whether this bean is "abstract", that is, not meant to be instantiated.
	 */
	boolean isAbstract();

	/**
	 * Return a description of the resource that this bean definition
	 * came from (for the purpose of showing context in case of errors).
	 */
	@Nullable
	String getResourceDescription();

	/**
	 * Return the originating BeanDefinition, or {@code null} if none.
	 * <p>Allows for retrieving the decorated bean definition, if any.
	 * <p>Note that this method returns the immediate originator. Iterate through the
	 * originator chain to find the original BeanDefinition as defined by the user.
	 */
	@Nullable
	BeanDefinition getOriginatingBeanDefinition();
}
```



## AbstractBeanDefinition



```java
package org.springframework.beans.factory.support;

/**
 * 包含了Bean的所有配置项和一些支持程序运行的属性
 * 
 * Base class for concrete, full-fledged {@link BeanDefinition} classes,
 * factoring out common properties of {@link GenericBeanDefinition},
 * {@link RootBeanDefinition}, and {@link ChildBeanDefinition}.
 *
 * <p>The autowire constants match the ones defined in the
 * {@link org.springframework.beans.factory.config.AutowireCapableBeanFactory}
 * interface.
 * 详见 GenericBeanDefinition
 * 详见 RootBeanDefinition
 * 详见 ChildBeanDefinition
 */
@SuppressWarnings("serial")
public abstract class AbstractBeanDefinition extends BeanMetadataAttributeAccessor implements BeanDefinition, Cloneable {

    /**
	 * Constant for the default scope name: {@code ""}, equivalent to singleton
	 * status unless overridden from a parent bean definition (if applicable).
	 */
    public static final String SCOPE_DEFAULT = "";

    /**
	 * Constant that indicates no external autowiring at all.
	 * @see #setAutowireMode
	 */
    public static final int AUTOWIRE_NO = AutowireCapableBeanFactory.AUTOWIRE_NO;

    /**
	 * Constant that indicates autowiring bean properties by name.
	 * @see #setAutowireMode
	 */
    public static final int AUTOWIRE_BY_NAME = AutowireCapableBeanFactory.AUTOWIRE_BY_NAME;

    /**
	 * Constant that indicates autowiring bean properties by type.
	 * @see #setAutowireMode
	 */
    public static final int AUTOWIRE_BY_TYPE = AutowireCapableBeanFactory.AUTOWIRE_BY_TYPE;

    /**
	 * Constant that indicates autowiring a constructor.
	 * @see #setAutowireMode
	 */
    public static final int AUTOWIRE_CONSTRUCTOR = AutowireCapableBeanFactory.AUTOWIRE_CONSTRUCTOR;

    /**
	 * Constant that indicates determining an appropriate autowire strategy
	 * through introspection of the bean class.
	 * @see #setAutowireMode
	 * @deprecated as of Spring 3.0: If you are using mixed autowiring strategies,
	 * use annotation-based autowiring for clearer demarcation of autowiring needs.
	 */
    @Deprecated
    public static final int AUTOWIRE_AUTODETECT = AutowireCapableBeanFactory.AUTOWIRE_AUTODETECT;

    /**
	 * Constant that indicates no dependency check at all.
	 * @see #setDependencyCheck
	 */
    public static final int DEPENDENCY_CHECK_NONE = 0;

    /**
	 * Constant that indicates dependency checking for object references.
	 * @see #setDependencyCheck
	 */
    public static final int DEPENDENCY_CHECK_OBJECTS = 1;

    /**
	 * Constant that indicates dependency checking for "simple" properties.
	 * @see #setDependencyCheck
	 * @see org.springframework.beans.BeanUtils#isSimpleProperty
	 */
    public static final int DEPENDENCY_CHECK_SIMPLE = 2;

    /**
	 * Constant that indicates dependency checking for all properties
	 * (object references as well as "simple" properties).
	 * @see #setDependencyCheck
	 */
    public static final int DEPENDENCY_CHECK_ALL = 3;

    /**
	 * Constant that indicates the container should attempt to infer the
	 * {@link #setDestroyMethodName destroy method name} for a bean as opposed to
	 * explicit specification of a method name. The value {@value} is specifically
	 * designed to include characters otherwise illegal in a method name, ensuring
	 * no possibility of collisions with legitimately named methods having the same
	 * name.
	 * <p>Currently, the method names detected during destroy method inference
	 * are "close" and "shutdown", if present on the specific bean class.
	 */
    public static final String INFER_METHOD = "(inferred)";

    /** bean 对应的类实例 */
    @Nullable
    private volatile Object beanClass;
    /** bean的作用域,对应scope属性 */
    @Nullable
    private String scope = SCOPE_DEFAULT;

    private boolean abstractFlag = false;

    @Nullable
    private Boolean lazyInit;

    private int autowireMode = AUTOWIRE_NO;

    private int dependencyCheck = DEPENDENCY_CHECK_NONE;

    @Nullable
    private String[] dependsOn;

    private boolean autowireCandidate = true;

    private boolean primary = false;

    private final Map<String, AutowireCandidateQualifier> qualifiers = new LinkedHashMap<>();

    @Nullable
    private Supplier<?> instanceSupplier;

    private boolean nonPublicAccessAllowed = true;

    private boolean lenientConstructorResolution = true;

    @Nullable
    private String factoryBeanName;

    @Nullable
    private String factoryMethodName;

    @Nullable
    private ConstructorArgumentValues constructorArgumentValues;

    @Nullable
    private MutablePropertyValues propertyValues;

    private MethodOverrides methodOverrides = new MethodOverrides();

    @Nullable
    private String initMethodName;

    @Nullable
    private String destroyMethodName;

    private boolean enforceInitMethod = true;

    private boolean enforceDestroyMethod = true;

    private boolean synthetic = false;

    private int role = BeanDefinition.ROLE_APPLICATION;

    @Nullable
    private String description;

    @Nullable
    private Resource resource;

    protected AbstractBeanDefinition() {
        this(null, null);
    }

    /**
	 * Create a new AbstractBeanDefinition with the given
	 * constructor argument values and property values.
	 */
    protected AbstractBeanDefinition(@Nullable ConstructorArgumentValues cargs, @Nullable MutablePropertyValues pvs) {
        this.constructorArgumentValues = cargs;
        this.propertyValues = pvs;
    }

    /**
	 * Create a new AbstractBeanDefinition as a deep copy of the given
	 * bean definition.
	 * @param original the original bean definition to copy from
	 */
    protected AbstractBeanDefinition(BeanDefinition original) {
        setParentName(original.getParentName());
        setBeanClassName(original.getBeanClassName());
        setScope(original.getScope());
        setAbstract(original.isAbstract());
        setFactoryBeanName(original.getFactoryBeanName());
        setFactoryMethodName(original.getFactoryMethodName());
        setRole(original.getRole());
        setSource(original.getSource());
        copyAttributesFrom(original);

        if (original instanceof AbstractBeanDefinition) {
            AbstractBeanDefinition originalAbd = (AbstractBeanDefinition) original;
            if (originalAbd.hasBeanClass()) {
                setBeanClass(originalAbd.getBeanClass());
            }
            if (originalAbd.hasConstructorArgumentValues()) {
                setConstructorArgumentValues(new ConstructorArgumentValues(original.getConstructorArgumentValues()));
            }
            if (originalAbd.hasPropertyValues()) {
                setPropertyValues(new MutablePropertyValues(original.getPropertyValues()));
            }
            if (originalAbd.hasMethodOverrides()) {
                setMethodOverrides(new MethodOverrides(originalAbd.getMethodOverrides()));
            }
            Boolean lazyInit = originalAbd.getLazyInit();
            if (lazyInit != null) {
                setLazyInit(lazyInit);
            }
            setAutowireMode(originalAbd.getAutowireMode());
            setDependencyCheck(originalAbd.getDependencyCheck());
            setDependsOn(originalAbd.getDependsOn());
            setAutowireCandidate(originalAbd.isAutowireCandidate());
            setPrimary(originalAbd.isPrimary());
            copyQualifiersFrom(originalAbd);
            setInstanceSupplier(originalAbd.getInstanceSupplier());
            setNonPublicAccessAllowed(originalAbd.isNonPublicAccessAllowed());
            setLenientConstructorResolution(originalAbd.isLenientConstructorResolution());
            setInitMethodName(originalAbd.getInitMethodName());
            setEnforceInitMethod(originalAbd.isEnforceInitMethod());
            setDestroyMethodName(originalAbd.getDestroyMethodName());
            setEnforceDestroyMethod(originalAbd.isEnforceDestroyMethod());
            setSynthetic(originalAbd.isSynthetic());
            setResource(originalAbd.getResource());
        }
        else {
            setConstructorArgumentValues(new ConstructorArgumentValues(original.getConstructorArgumentValues()));
            setPropertyValues(new MutablePropertyValues(original.getPropertyValues()));
            setLazyInit(original.isLazyInit());
            setResourceDescription(original.getResourceDescription());
        }
    }


    /**
	 * Override settings in this bean definition (presumably a copied parent
	 * from a parent-child inheritance relationship) from the given bean
	 * definition (presumably the child).
	 * <ul>
	 * <li>Will override beanClass if specified in the given bean definition.
	 * <li>Will always take {@code abstract}, {@code scope},
	 * {@code lazyInit}, {@code autowireMode}, {@code dependencyCheck},
	 * and {@code dependsOn} from the given bean definition.
	 * <li>Will add {@code constructorArgumentValues}, {@code propertyValues},
	 * {@code methodOverrides} from the given bean definition to existing ones.
	 * <li>Will override {@code factoryBeanName}, {@code factoryMethodName},
	 * {@code initMethodName}, and {@code destroyMethodName} if specified
	 * in the given bean definition.
	 * </ul>
	 */
    public void overrideFrom(BeanDefinition other) {
        if (StringUtils.hasLength(other.getBeanClassName())) {
            setBeanClassName(other.getBeanClassName());
        }
        if (StringUtils.hasLength(other.getScope())) {
            setScope(other.getScope());
        }
        setAbstract(other.isAbstract());
        if (StringUtils.hasLength(other.getFactoryBeanName())) {
            setFactoryBeanName(other.getFactoryBeanName());
        }
        if (StringUtils.hasLength(other.getFactoryMethodName())) {
            setFactoryMethodName(other.getFactoryMethodName());
        }
        setRole(other.getRole());
        setSource(other.getSource());
        copyAttributesFrom(other);

        if (other instanceof AbstractBeanDefinition) {
            AbstractBeanDefinition otherAbd = (AbstractBeanDefinition) other;
            if (otherAbd.hasBeanClass()) {
                setBeanClass(otherAbd.getBeanClass());
            }
            if (otherAbd.hasConstructorArgumentValues()) {
                getConstructorArgumentValues().addArgumentValues(other.getConstructorArgumentValues());
            }
            if (otherAbd.hasPropertyValues()) {
                getPropertyValues().addPropertyValues(other.getPropertyValues());
            }
            if (otherAbd.hasMethodOverrides()) {
                getMethodOverrides().addOverrides(otherAbd.getMethodOverrides());
            }
            Boolean lazyInit = otherAbd.getLazyInit();
            if (lazyInit != null) {
                setLazyInit(lazyInit);
            }
            setAutowireMode(otherAbd.getAutowireMode());
            setDependencyCheck(otherAbd.getDependencyCheck());
            setDependsOn(otherAbd.getDependsOn());
            setAutowireCandidate(otherAbd.isAutowireCandidate());
            setPrimary(otherAbd.isPrimary());
            copyQualifiersFrom(otherAbd);
            setInstanceSupplier(otherAbd.getInstanceSupplier());
            setNonPublicAccessAllowed(otherAbd.isNonPublicAccessAllowed());
            setLenientConstructorResolution(otherAbd.isLenientConstructorResolution());
            if (otherAbd.getInitMethodName() != null) {
                setInitMethodName(otherAbd.getInitMethodName());
                setEnforceInitMethod(otherAbd.isEnforceInitMethod());
            }
            if (otherAbd.getDestroyMethodName() != null) {
                setDestroyMethodName(otherAbd.getDestroyMethodName());
                setEnforceDestroyMethod(otherAbd.isEnforceDestroyMethod());
            }
            setSynthetic(otherAbd.isSynthetic());
            setResource(otherAbd.getResource());
        }
        else {
            getConstructorArgumentValues().addArgumentValues(other.getConstructorArgumentValues());
            getPropertyValues().addPropertyValues(other.getPropertyValues());
            setLazyInit(other.isLazyInit());
            setResourceDescription(other.getResourceDescription());
        }
    }

    /**
	 * Apply the provided default values to this bean.
	 * @param defaults the default settings to apply
	 */
    public void applyDefaults(BeanDefinitionDefaults defaults) {
        Boolean lazyInit = defaults.getLazyInit();
        if (lazyInit != null) {
            setLazyInit(lazyInit);
        }
        setAutowireMode(defaults.getAutowireMode());
        setDependencyCheck(defaults.getDependencyCheck());
        setInitMethodName(defaults.getInitMethodName());
        setEnforceInitMethod(false);
        setDestroyMethodName(defaults.getDestroyMethodName());
        setEnforceDestroyMethod(false);
    }

    /**
	 * Specify the bean class name of this bean definition.
	 */
    @Override
    public void setBeanClassName(@Nullable String beanClassName) {
        this.beanClass = beanClassName;
    }

    /**
	 * Return the current bean class name of this bean definition.
	 */
    @Override
    @Nullable
    public String getBeanClassName() {
        Object beanClassObject = this.beanClass;
        if (beanClassObject instanceof Class) {
            return ((Class<?>) beanClassObject).getName();
        }
        else {
            return (String) beanClassObject;
        }
    }

    /**
	 * Specify the class for this bean.
	 * @see #setBeanClassName(String)
	 */
    public void setBeanClass(@Nullable Class<?> beanClass) {
        this.beanClass = beanClass;
    }

    /**
	 * Return the specified class of the bean definition (assuming it is resolved already).
	 * <p><b>NOTE:</b> This is an initial class reference as declared in the bean metadata
	 * definition, potentially combined with a declared factory method or a
	 * {@link org.springframework.beans.factory.FactoryBean} which may lead to a different
	 * runtime type of the bean, or not being set at all in case of an instance-level
	 * factory method (which is resolved via {@link #getFactoryBeanName()} instead).
	 * <b>Do not use this for runtime type introspection of arbitrary bean definitions.</b>
	 * The recommended way to find out about the actual runtime type of a particular bean
	 * is a {@link org.springframework.beans.factory.BeanFactory#getType} call for the
	 * specified bean name; this takes all of the above cases into account and returns the
	 * type of object that a {@link org.springframework.beans.factory.BeanFactory#getBean}
	 * call is going to return for the same bean name.
	 * @return the resolved bean class (never {@code null})
	 * @throws IllegalStateException if the bean definition does not define a bean class,
	 * or a specified bean class name has not been resolved into an actual Class yet
	 * @see #getBeanClassName()
	 * @see #hasBeanClass()
	 * @see #setBeanClass(Class)
	 * @see #resolveBeanClass(ClassLoader)
	 */
    public Class<?> getBeanClass() throws IllegalStateException {
        Object beanClassObject = this.beanClass;
        if (beanClassObject == null) {
            throw new IllegalStateException("No bean class specified on bean definition");
        }
        if (!(beanClassObject instanceof Class)) {
            throw new IllegalStateException(
                "Bean class name [" + beanClassObject + "] has not been resolved into an actual Class");
        }
        return (Class<?>) beanClassObject;
    }

    /**
	 * Return whether this definition specifies a bean class.
	 * @see #getBeanClass()
	 * @see #setBeanClass(Class)
	 * @see #resolveBeanClass(ClassLoader)
	 */
    public boolean hasBeanClass() {
        return (this.beanClass instanceof Class);
    }

    /**
	 * Determine the class of the wrapped bean, resolving it from a
	 * specified class name if necessary. Will also reload a specified
	 * Class from its name when called with the bean class already resolved.
	 * @param classLoader the ClassLoader to use for resolving a (potential) class name
	 * @return the resolved bean class
	 * @throws ClassNotFoundException if the class name could be resolved
	 */
    @Nullable
    public Class<?> resolveBeanClass(@Nullable ClassLoader classLoader) throws ClassNotFoundException {
        String className = getBeanClassName();
        if (className == null) {
            return null;
        }
        Class<?> resolvedClass = ClassUtils.forName(className, classLoader);
        this.beanClass = resolvedClass;
        return resolvedClass;
    }

    /**
	 * Return a resolvable type for this bean definition.
	 * <p>This implementation delegates to {@link #getBeanClass()}.
	 * @since 5.2
	 */
    @Override
    public ResolvableType getResolvableType() {
        return (hasBeanClass() ? ResolvableType.forClass(getBeanClass()) : ResolvableType.NONE);
    }

    /**
	 * Set the name of the target scope for the bean.
	 * <p>The default is singleton status, although this is only applied once
	 * a bean definition becomes active in the containing factory. A bean
	 * definition may eventually inherit its scope from a parent bean definition.
	 * For this reason, the default scope name is an empty string (i.e., {@code ""}),
	 * with singleton status being assumed until a resolved scope is set.
	 * @see #SCOPE_SINGLETON
	 * @see #SCOPE_PROTOTYPE
	 */
    @Override
    public void setScope(@Nullable String scope) {
        this.scope = scope;
    }

    /**
	 * Return the name of the target scope for the bean.
	 */
    @Override
    @Nullable
    public String getScope() {
        return this.scope;
    }

    /**
	 * Return whether this a <b>Singleton</b>, with a single shared instance
	 * returned from all calls.
	 * @see #SCOPE_SINGLETON
	 */
    @Override
    public boolean isSingleton() {
        return SCOPE_SINGLETON.equals(this.scope) || SCOPE_DEFAULT.equals(this.scope);
    }

    /**
	 * Return whether this a <b>Prototype</b>, with an independent instance
	 * returned for each call.
	 * @see #SCOPE_PROTOTYPE
	 */
    @Override
    public boolean isPrototype() {
        return SCOPE_PROTOTYPE.equals(this.scope);
    }

    /**
	 * Set if this bean is "abstract", i.e. not meant to be instantiated itself but
	 * rather just serving as parent for concrete child bean definitions.
	 * <p>Default is "false". Specify true to tell the bean factory to not try to
	 * instantiate that particular bean in any case.
	 */
    public void setAbstract(boolean abstractFlag) {
        this.abstractFlag = abstractFlag;
    }

    /**
	 * Return whether this bean is "abstract", i.e. not meant to be instantiated
	 * itself but rather just serving as parent for concrete child bean definitions.
	 */
    @Override
    public boolean isAbstract() {
        return this.abstractFlag;
    }

    /**
	 * Set whether this bean should be lazily initialized.
	 * <p>If {@code false}, the bean will get instantiated on startup by bean
	 * factories that perform eager initialization of singletons.
	 */
    @Override
    public void setLazyInit(boolean lazyInit) {
        this.lazyInit = lazyInit;
    }

    /**
	 * Return whether this bean should be lazily initialized, i.e. not
	 * eagerly instantiated on startup. Only applicable to a singleton bean.
	 * @return whether to apply lazy-init semantics ({@code false} by default)
	 */
    @Override
    public boolean isLazyInit() {
        return (this.lazyInit != null && this.lazyInit.booleanValue());
    }

    /**
	 * Return whether this bean should be lazily initialized, i.e. not
	 * eagerly instantiated on startup. Only applicable to a singleton bean.
	 * @return the lazy-init flag if explicitly set, or {@code null} otherwise
	 * @since 5.2
	 */
    @Nullable
    public Boolean getLazyInit() {
        return this.lazyInit;
    }

    /**
	 * Set the autowire mode. This determines whether any automagical detection
	 * and setting of bean references will happen. Default is AUTOWIRE_NO
	 * which means there won't be convention-based autowiring by name or type
	 * (however, there may still be explicit annotation-driven autowiring).
	 * @param autowireMode the autowire mode to set.
	 * Must be one of the constants defined in this class.
	 * @see #AUTOWIRE_NO
	 * @see #AUTOWIRE_BY_NAME
	 * @see #AUTOWIRE_BY_TYPE
	 * @see #AUTOWIRE_CONSTRUCTOR
	 * @see #AUTOWIRE_AUTODETECT
	 */
    public void setAutowireMode(int autowireMode) {
        this.autowireMode = autowireMode;
    }

    /**
	 * Return the autowire mode as specified in the bean definition.
	 */
    public int getAutowireMode() {
        return this.autowireMode;
    }

    /**
	 * Return the resolved autowire code,
	 * (resolving AUTOWIRE_AUTODETECT to AUTOWIRE_CONSTRUCTOR or AUTOWIRE_BY_TYPE).
	 * @see #AUTOWIRE_AUTODETECT
	 * @see #AUTOWIRE_CONSTRUCTOR
	 * @see #AUTOWIRE_BY_TYPE
	 */
    public int getResolvedAutowireMode() {
        if (this.autowireMode == AUTOWIRE_AUTODETECT) {
            // Work out whether to apply setter autowiring or constructor autowiring.
            // If it has a no-arg constructor it's deemed to be setter autowiring,
            // otherwise we'll try constructor autowiring.
            Constructor<?>[] constructors = getBeanClass().getConstructors();
            for (Constructor<?> constructor : constructors) {
                if (constructor.getParameterCount() == 0) {
                    return AUTOWIRE_BY_TYPE;
                }
            }
            return AUTOWIRE_CONSTRUCTOR;
        }
        else {
            return this.autowireMode;
        }
    }

    /**
	 * Set the dependency check code.
	 * @param dependencyCheck the code to set.
	 * Must be one of the four constants defined in this class.
	 * @see #DEPENDENCY_CHECK_NONE
	 * @see #DEPENDENCY_CHECK_OBJECTS
	 * @see #DEPENDENCY_CHECK_SIMPLE
	 * @see #DEPENDENCY_CHECK_ALL
	 */
    public void setDependencyCheck(int dependencyCheck) {
        this.dependencyCheck = dependencyCheck;
    }

    /**
	 * Return the dependency check code.
	 */
    public int getDependencyCheck() {
        return this.dependencyCheck;
    }

    /**
	 * Set the names of the beans that this bean depends on being initialized.
	 * The bean factory will guarantee that these beans get initialized first.
	 * <p>Note that dependencies are normally expressed through bean properties or
	 * constructor arguments. This property should just be necessary for other kinds
	 * of dependencies like statics (*ugh*) or database preparation on startup.
	 */
    @Override
    public void setDependsOn(@Nullable String... dependsOn) {
        this.dependsOn = dependsOn;
    }

    /**
	 * Return the bean names that this bean depends on.
	 */
    @Override
    @Nullable
    public String[] getDependsOn() {
        return this.dependsOn;
    }

    /**
	 * Set whether this bean is a candidate for getting autowired into some other bean.
	 * <p>Note that this flag is designed to only affect type-based autowiring.
	 * It does not affect explicit references by name, which will get resolved even
	 * if the specified bean is not marked as an autowire candidate. As a consequence,
	 * autowiring by name will nevertheless inject a bean if the name matches.
	 * @see #AUTOWIRE_BY_TYPE
	 * @see #AUTOWIRE_BY_NAME
	 */
    @Override
    public void setAutowireCandidate(boolean autowireCandidate) {
        this.autowireCandidate = autowireCandidate;
    }

    /**
	 * Return whether this bean is a candidate for getting autowired into some other bean.
	 */
    @Override
    public boolean isAutowireCandidate() {
        return this.autowireCandidate;
    }

    /**
	 * Set whether this bean is a primary autowire candidate.
	 * <p>If this value is {@code true} for exactly one bean among multiple
	 * matching candidates, it will serve as a tie-breaker.
	 */
    @Override
    public void setPrimary(boolean primary) {
        this.primary = primary;
    }

    /**
	 * Return whether this bean is a primary autowire candidate.
	 */
    @Override
    public boolean isPrimary() {
        return this.primary;
    }

    /**
	 * Register a qualifier to be used for autowire candidate resolution,
	 * keyed by the qualifier's type name.
	 * @see AutowireCandidateQualifier#getTypeName()
	 */
    public void addQualifier(AutowireCandidateQualifier qualifier) {
        this.qualifiers.put(qualifier.getTypeName(), qualifier);
    }

    /**
	 * Return whether this bean has the specified qualifier.
	 */
    public boolean hasQualifier(String typeName) {
        return this.qualifiers.containsKey(typeName);
    }

    /**
	 * Return the qualifier mapped to the provided type name.
	 */
    @Nullable
    public AutowireCandidateQualifier getQualifier(String typeName) {
        return this.qualifiers.get(typeName);
    }

    /**
	 * Return all registered qualifiers.
	 * @return the Set of {@link AutowireCandidateQualifier} objects.
	 */
    public Set<AutowireCandidateQualifier> getQualifiers() {
        return new LinkedHashSet<>(this.qualifiers.values());
    }

    /**
	 * Copy the qualifiers from the supplied AbstractBeanDefinition to this bean definition.
	 * @param source the AbstractBeanDefinition to copy from
	 */
    public void copyQualifiersFrom(AbstractBeanDefinition source) {
        Assert.notNull(source, "Source must not be null");
        this.qualifiers.putAll(source.qualifiers);
    }

    /**
	 * Specify a callback for creating an instance of the bean,
	 * as an alternative to a declaratively specified factory method.
	 * <p>If such a callback is set, it will override any other constructor
	 * or factory method metadata. However, bean property population and
	 * potential annotation-driven injection will still apply as usual.
	 * @since 5.0
	 * @see #setConstructorArgumentValues(ConstructorArgumentValues)
	 * @see #setPropertyValues(MutablePropertyValues)
	 */
    public void setInstanceSupplier(@Nullable Supplier<?> instanceSupplier) {
        this.instanceSupplier = instanceSupplier;
    }

    /**
	 * Return a callback for creating an instance of the bean, if any.
	 * @since 5.0
	 */
    @Nullable
    public Supplier<?> getInstanceSupplier() {
        return this.instanceSupplier;
    }

    /**
	 * Specify whether to allow access to non-public constructors and methods,
	 * for the case of externalized metadata pointing to those. The default is
	 * {@code true}; switch this to {@code false} for public access only.
	 * <p>This applies to constructor resolution, factory method resolution,
	 * and also init/destroy methods. Bean property accessors have to be public
	 * in any case and are not affected by this setting.
	 * <p>Note that annotation-driven configuration will still access non-public
	 * members as far as they have been annotated. This setting applies to
	 * externalized metadata in this bean definition only.
	 */
    public void setNonPublicAccessAllowed(boolean nonPublicAccessAllowed) {
        this.nonPublicAccessAllowed = nonPublicAccessAllowed;
    }

    /**
	 * Return whether to allow access to non-public constructors and methods.
	 */
    public boolean isNonPublicAccessAllowed() {
        return this.nonPublicAccessAllowed;
    }

    /**
	 * Specify whether to resolve constructors in lenient mode ({@code true},
	 * which is the default) or to switch to strict resolution (throwing an exception
	 * in case of ambiguous constructors that all match when converting the arguments,
	 * whereas lenient mode would use the one with the 'closest' type matches).
	 */
    public void setLenientConstructorResolution(boolean lenientConstructorResolution) {
        this.lenientConstructorResolution = lenientConstructorResolution;
    }

    /**
	 * Return whether to resolve constructors in lenient mode or in strict mode.
	 */
    public boolean isLenientConstructorResolution() {
        return this.lenientConstructorResolution;
    }

    /**
	 * Specify the factory bean to use, if any.
	 * This the name of the bean to call the specified factory method on.
	 * @see #setFactoryMethodName
	 */
    @Override
    public void setFactoryBeanName(@Nullable String factoryBeanName) {
        this.factoryBeanName = factoryBeanName;
    }

    /**
	 * Return the factory bean name, if any.
	 */
    @Override
    @Nullable
    public String getFactoryBeanName() {
        return this.factoryBeanName;
    }

    /**
	 * Specify a factory method, if any. This method will be invoked with
	 * constructor arguments, or with no arguments if none are specified.
	 * The method will be invoked on the specified factory bean, if any,
	 * or otherwise as a static method on the local bean class.
	 * @see #setFactoryBeanName
	 * @see #setBeanClassName
	 */
    @Override
    public void setFactoryMethodName(@Nullable String factoryMethodName) {
        this.factoryMethodName = factoryMethodName;
    }

    /**
	 * Return a factory method, if any.
	 */
    @Override
    @Nullable
    public String getFactoryMethodName() {
        return this.factoryMethodName;
    }

    /**
	 * Specify constructor argument values for this bean.
	 */
    public void setConstructorArgumentValues(ConstructorArgumentValues constructorArgumentValues) {
        this.constructorArgumentValues = constructorArgumentValues;
    }

    /**
	 * Return constructor argument values for this bean (never {@code null}).
	 */
    @Override
    public ConstructorArgumentValues getConstructorArgumentValues() {
        if (this.constructorArgumentValues == null) {
            this.constructorArgumentValues = new ConstructorArgumentValues();
        }
        return this.constructorArgumentValues;
    }

    /**
	 * Return if there are constructor argument values defined for this bean.
	 */
    @Override
    public boolean hasConstructorArgumentValues() {
        return (this.constructorArgumentValues != null && !this.constructorArgumentValues.isEmpty());
    }

    /**
	 * Specify property values for this bean, if any.
	 */
    public void setPropertyValues(MutablePropertyValues propertyValues) {
        this.propertyValues = propertyValues;
    }

    /**
	 * Return property values for this bean (never {@code null}).
	 */
    @Override
    public MutablePropertyValues getPropertyValues() {
        if (this.propertyValues == null) {
            this.propertyValues = new MutablePropertyValues();
        }
        return this.propertyValues;
    }

    /**
	 * Return if there are property values values defined for this bean.
	 * @since 5.0.2
	 */
    @Override
    public boolean hasPropertyValues() {
        return (this.propertyValues != null && !this.propertyValues.isEmpty());
    }

    /**
	 * Specify method overrides for the bean, if any.
	 */
    public void setMethodOverrides(MethodOverrides methodOverrides) {
        this.methodOverrides = methodOverrides;
    }

    /**
	 * Return information about methods to be overridden by the IoC
	 * container. This will be empty if there are no method overrides.
	 * <p>Never returns {@code null}.
	 */
    public MethodOverrides getMethodOverrides() {
        return this.methodOverrides;
    }

    /**
	 * Return if there are method overrides defined for this bean.
	 * @since 5.0.2
	 */
    public boolean hasMethodOverrides() {
        return !this.methodOverrides.isEmpty();
    }

    /**
	 * Set the name of the initializer method.
	 * <p>The default is {@code null} in which case there is no initializer method.
	 */
    @Override
    public void setInitMethodName(@Nullable String initMethodName) {
        this.initMethodName = initMethodName;
    }

    /**
	 * Return the name of the initializer method.
	 */
    @Override
    @Nullable
    public String getInitMethodName() {
        return this.initMethodName;
    }

    /**
	 * Specify whether or not the configured initializer method is the default.
	 * <p>The default value is {@code true} for a locally specified init method
	 * but switched to {@code false} for a shared setting in a defaults section
	 * (e.g. {@code bean init-method} versus {@code beans default-init-method}
	 * level in XML) which might not apply to all contained bean definitions.
	 * @see #setInitMethodName
	 * @see #applyDefaults
	 */
    public void setEnforceInitMethod(boolean enforceInitMethod) {
        this.enforceInitMethod = enforceInitMethod;
    }

    /**
	 * Indicate whether the configured initializer method is the default.
	 * @see #getInitMethodName()
	 */
    public boolean isEnforceInitMethod() {
        return this.enforceInitMethod;
    }

    /**
	 * Set the name of the destroy method.
	 * <p>The default is {@code null} in which case there is no destroy method.
	 */
    @Override
    public void setDestroyMethodName(@Nullable String destroyMethodName) {
        this.destroyMethodName = destroyMethodName;
    }

    /**
	 * Return the name of the destroy method.
	 */
    @Override
    @Nullable
    public String getDestroyMethodName() {
        return this.destroyMethodName;
    }

    /**
	 * Specify whether or not the configured destroy method is the default.
	 * <p>The default value is {@code true} for a locally specified destroy method
	 * but switched to {@code false} for a shared setting in a defaults section
	 * (e.g. {@code bean destroy-method} versus {@code beans default-destroy-method}
	 * level in XML) which might not apply to all contained bean definitions.
	 * @see #setDestroyMethodName
	 * @see #applyDefaults
	 */
    public void setEnforceDestroyMethod(boolean enforceDestroyMethod) {
        this.enforceDestroyMethod = enforceDestroyMethod;
    }

    /**
	 * Indicate whether the configured destroy method is the default.
	 * @see #getDestroyMethodName()
	 */
    public boolean isEnforceDestroyMethod() {
        return this.enforceDestroyMethod;
    }

    /**
	 * Set whether this bean definition is 'synthetic', that is, not defined
	 * by the application itself (for example, an infrastructure bean such
	 * as a helper for auto-proxying, created through {@code <aop:config>}).
	 */
    public void setSynthetic(boolean synthetic) {
        this.synthetic = synthetic;
    }

    /**
	 * Return whether this bean definition is 'synthetic', that is,
	 * not defined by the application itself.
	 */
    public boolean isSynthetic() {
        return this.synthetic;
    }

    /**
	 * Set the role hint for this {@code BeanDefinition}.
	 */
    @Override
    public void setRole(int role) {
        this.role = role;
    }

    /**
	 * Return the role hint for this {@code BeanDefinition}.
	 */
    @Override
    public int getRole() {
        return this.role;
    }

    /**
	 * Set a human-readable description of this bean definition.
	 */
    @Override
    public void setDescription(@Nullable String description) {
        this.description = description;
    }

    /**
	 * Return a human-readable description of this bean definition.
	 */
    @Override
    @Nullable
    public String getDescription() {
        return this.description;
    }

    /**
	 * Set the resource that this bean definition came from
	 * (for the purpose of showing context in case of errors).
	 */
    public void setResource(@Nullable Resource resource) {
        this.resource = resource;
    }

    /**
	 * Return the resource that this bean definition came from.
	 */
    @Nullable
    public Resource getResource() {
        return this.resource;
    }

    /**
	 * Set a description of the resource that this bean definition
	 * came from (for the purpose of showing context in case of errors).
	 */
    public void setResourceDescription(@Nullable String resourceDescription) {
        this.resource = (resourceDescription != null ? new DescriptiveResource(resourceDescription) : null);
    }

    /**
	 * Return a description of the resource that this bean definition
	 * came from (for the purpose of showing context in case of errors).
	 */
    @Override
    @Nullable
    public String getResourceDescription() {
        return (this.resource != null ? this.resource.getDescription() : null);
    }

    /**
	 * Set the originating (e.g. decorated) BeanDefinition, if any.
	 */
    public void setOriginatingBeanDefinition(BeanDefinition originatingBd) {
        this.resource = new BeanDefinitionResource(originatingBd);
    }

    /**
	 * Return the originating BeanDefinition, or {@code null} if none.
	 * Allows for retrieving the decorated bean definition, if any.
	 * <p>Note that this method returns the immediate originator. Iterate through the
	 * originator chain to find the original BeanDefinition as defined by the user.
	 */
    @Override
    @Nullable
    public BeanDefinition getOriginatingBeanDefinition() {
        return (this.resource instanceof BeanDefinitionResource ?
                ((BeanDefinitionResource) this.resource).getBeanDefinition() : null);
    }

    /**
	 * Validate this bean definition.
	 * @throws BeanDefinitionValidationException in case of validation failure
	 */
    public void validate() throws BeanDefinitionValidationException {
        if (hasMethodOverrides() && getFactoryMethodName() != null) {
            throw new BeanDefinitionValidationException(
                "Cannot combine factory method with container-generated method overrides: " +
                "the factory method must create the concrete bean instance.");
        }
        if (hasBeanClass()) {
            prepareMethodOverrides();
        }
    }

    /**
	 * Validate and prepare the method overrides defined for this bean.
	 * Checks for existence of a method with the specified name.
	 * @throws BeanDefinitionValidationException in case of validation failure
	 */
    public void prepareMethodOverrides() throws BeanDefinitionValidationException {
        // Check that lookup methods exist and determine their overloaded status.
        if (hasMethodOverrides()) {
            getMethodOverrides().getOverrides().forEach(this::prepareMethodOverride);
        }
    }

    /**
	 * Validate and prepare the given method override.
	 * Checks for existence of a method with the specified name,
	 * marking it as not overloaded if none found.
	 * @param mo the MethodOverride object to validate
	 * @throws BeanDefinitionValidationException in case of validation failure
	 */
    protected void prepareMethodOverride(MethodOverride mo) throws BeanDefinitionValidationException {
        int count = ClassUtils.getMethodCountForName(getBeanClass(), mo.getMethodName());
        if (count == 0) {
            throw new BeanDefinitionValidationException(
                "Invalid method override: no method with name '" + mo.getMethodName() +
                "' on class [" + getBeanClassName() + "]");
        }
        else if (count == 1) {
            // Mark override as not overloaded, to avoid the overhead of arg type checking.
            mo.setOverloaded(false);
        }
    }


    /**
	 * Public declaration of Object's {@code clone()} method.
	 * Delegates to {@link #cloneBeanDefinition()}.
	 * @see Object#clone()
	 */
    @Override
    public Object clone() {
        return cloneBeanDefinition();
    }

    /**
	 * Clone this bean definition.
	 * To be implemented by concrete subclasses.
	 * @return the cloned bean definition object
	 */
    public abstract AbstractBeanDefinition cloneBeanDefinition();

    @Override
    public boolean equals(@Nullable Object other) {
        if (this == other) {
            return true;
        }
        if (!(other instanceof AbstractBeanDefinition)) {
            return false;
        }
        AbstractBeanDefinition that = (AbstractBeanDefinition) other;
        return (ObjectUtils.nullSafeEquals(getBeanClassName(), that.getBeanClassName()) &&
                ObjectUtils.nullSafeEquals(this.scope, that.scope) &&
                this.abstractFlag == that.abstractFlag &&
                this.lazyInit == that.lazyInit &&
                this.autowireMode == that.autowireMode &&
                this.dependencyCheck == that.dependencyCheck &&
                Arrays.equals(this.dependsOn, that.dependsOn) &&
                this.autowireCandidate == that.autowireCandidate &&
                ObjectUtils.nullSafeEquals(this.qualifiers, that.qualifiers) &&
                this.primary == that.primary &&
                this.nonPublicAccessAllowed == that.nonPublicAccessAllowed &&
                this.lenientConstructorResolution == that.lenientConstructorResolution &&
                ObjectUtils.nullSafeEquals(this.constructorArgumentValues, that.constructorArgumentValues) &&
                ObjectUtils.nullSafeEquals(this.propertyValues, that.propertyValues) &&
                ObjectUtils.nullSafeEquals(this.methodOverrides, that.methodOverrides) &&
                ObjectUtils.nullSafeEquals(this.factoryBeanName, that.factoryBeanName) &&
                ObjectUtils.nullSafeEquals(this.factoryMethodName, that.factoryMethodName) &&
                ObjectUtils.nullSafeEquals(this.initMethodName, that.initMethodName) &&
                this.enforceInitMethod == that.enforceInitMethod &&
                ObjectUtils.nullSafeEquals(this.destroyMethodName, that.destroyMethodName) &&
                this.enforceDestroyMethod == that.enforceDestroyMethod &&
                this.synthetic == that.synthetic &&
                this.role == that.role &&
                super.equals(other));
    }

    @Override
    public int hashCode() {
        int hashCode = ObjectUtils.nullSafeHashCode(getBeanClassName());
        hashCode = 29 * hashCode + ObjectUtils.nullSafeHashCode(this.scope);
        hashCode = 29 * hashCode + ObjectUtils.nullSafeHashCode(this.constructorArgumentValues);
        hashCode = 29 * hashCode + ObjectUtils.nullSafeHashCode(this.propertyValues);
        hashCode = 29 * hashCode + ObjectUtils.nullSafeHashCode(this.factoryBeanName);
        hashCode = 29 * hashCode + ObjectUtils.nullSafeHashCode(this.factoryMethodName);
        hashCode = 29 * hashCode + super.hashCode();
        return hashCode;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder("class [");
        sb.append(getBeanClassName()).append("]");
        sb.append("; scope=").append(this.scope);
        sb.append("; abstract=").append(this.abstractFlag);
        sb.append("; lazyInit=").append(this.lazyInit);
        sb.append("; autowireMode=").append(this.autowireMode);
        sb.append("; dependencyCheck=").append(this.dependencyCheck);
        sb.append("; autowireCandidate=").append(this.autowireCandidate);
        sb.append("; primary=").append(this.primary);
        sb.append("; factoryBeanName=").append(this.factoryBeanName);
        sb.append("; factoryMethodName=").append(this.factoryMethodName);
        sb.append("; initMethodName=").append(this.initMethodName);
        sb.append("; destroyMethodName=").append(this.destroyMethodName);
        if (this.resource != null) {
            sb.append("; defined in ").append(this.resource.getDescription());
        }
        return sb.toString();
    }
}
```



# BeanDefinitionRegistry



* 该接口定义了对BeanDefinition的各种增删改查操作,类似于内存数据库



## SimpleBeanDefinitionRegistry



```java
package org.springframework.beans.factory.support;

/**
 * BeanDefinitionRegistry的简单实现,利用Map实现存储
 *
 * 仅提供注册表功能,不内置工厂功能,例如可以用于测试bean定义读取器
 */
public class SimpleBeanDefinitionRegistry extends SimpleAliasRegistry implements BeanDefinitionRegistry {

    /** Map of bean definition objects, keyed by bean name. */
    private final Map<String, BeanDefinition> beanDefinitionMap = new ConcurrentHashMap<>(64);

    @Override
    public void registerBeanDefinition(String beanName, BeanDefinition beanDefinition)
        throws BeanDefinitionStoreException {

        Assert.hasText(beanName, "'beanName' must not be empty");
        Assert.notNull(beanDefinition, "BeanDefinition must not be null");
        this.beanDefinitionMap.put(beanName, beanDefinition);
    }

    @Override
    public void removeBeanDefinition(String beanName) throws NoSuchBeanDefinitionException {
        if (this.beanDefinitionMap.remove(beanName) == null) {
            throw new NoSuchBeanDefinitionException(beanName);
        }
    }

    @Override
    public BeanDefinition getBeanDefinition(String beanName) throws NoSuchBeanDefinitionException {
        BeanDefinition bd = this.beanDefinitionMap.get(beanName);
        if (bd == null) {
            throw new NoSuchBeanDefinitionException(beanName);
        }
        return bd;
    }

    ...
}
```



# AnnotationConfigRegistry



```java
package org.springframework.context.annotation;

/**
 * 注解配置应用程序上下文的公共接口,可通过下面2个方法将Bean输入到Spring容器中
 *
 * AnnotationConfigApplicationContext实现该接口
 */
public interface AnnotationConfigRegistry {

	/**
	 * Register one or more component classes to be processed.
	 * <p>Calls to {@code register} are idempotent; adding the same
	 * component class more than once has no additional effect.
	 * @param componentClasses one or more component classes,
	 * e.g. {@link Configuration @Configuration} classes
	 */
	void register(Class<?>... componentClasses);

	/**
	 * Perform a scan within the specified base packages.
	 * @param basePackages the packages to scan for component classes
	 */
	void scan(String... basePackages);
}
```


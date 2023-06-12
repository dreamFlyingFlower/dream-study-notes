# MySQLConfig



```mysql
# 客户端配置文件
[client]
socket=/app/mysql/data/mysql.sock
# 客户端端口
port = 3306
# 客户端字符集
default-character-set=utf8

# 服务端配置文件
[mysqld]

# 主键自增长默认步长
auto_increment_increment=1
# 主键自增长起始值
auto_increment_offset=1
# 自动提交事务,0/OFF为手动提交,1/ON自动提交
autocommit=ON
automatic_sp_privileges=ON
avoid_temporal_upgrade=OFF

# 连接堆栈大小.MySQL连接数据达到max_connections时,新来的请求将会被存在堆栈中,以等待连接释放,如果等待连接数超过back_log,将不被授予连接资源
back_log=1024
# 安装目录
basedir=/usr/local/mysql
big_tables=OFF
# 可访问数据库的ip地址,默认只能是本地访问
bind_address=0.0.0.0
block_encryption_mode=aes-128-ecb
bulk_insert_buffer_size=8388608

# 字符集相关
# 客户字符集
character_set_client=utf8
# 链接字符集
character_set_connection=utf8
# 数据库字符集
character_set_database=utf8
# 文件系统格式
character_set_filesystem=binary
# 结果字符集
character_set_results=utf8
# 服务端字符集
character_set_server=utf8
# 系统字符集
character_set_system=utf8
# 字符集目录
character_sets_dir=/usr/local/mysql/share/charsets/
collation_connection=utf8_general_ci
collation_database=utf8_general_ci
collation_server=utf8_general_ci

# bin_log相关
# 是否开启bin_log,默认关闭.生产环境一定要开启,所有对数据库的更新操作都会记录到该文件中.可指定该文件的名称
log_bin=ON
# bin_log日志名称,可不配置
log_bin_basename=/usr/local/mysql/sql_log/mysql-bin
# bin_log日志索引名称,可不配置
log_bin_index=/usr/local/mysql/sql_log/mysql-bin.index
log_bin_trust_function_creators=OFF
log_bin_use_v1_row_events=OFF
# bin_log日志缓存大小,字节
binlog_cache_size=32768
binlog_checksum=CRC32
binlog_direct_non_transactional_updates=OFF
# bin_log中只记录某些数据库,多个用逗号隔开或写多行
binlog_do_db=mysql
binlog_error_action=IGNORE_ERROR
# bin-log的类型,row,statement,mixed
binlog_format=ROW
binlog_gtid_simple_recovery=OFF
# binlog日志中,忽略同步的表,多个用逗号隔开或写多行
binlog_ignore_db=mysql,performance-schema
binlog_max_flush_queue_time	0
binlog_order_commits=ON
binlog_row_image=FULL
binlog_rows_query_log_events=OFF
binlog_stmt_cache_size=32768
binlogging_impossible_mode=IGNORE_ERROR

# 慢查询相关
# 开启慢日志,默认不开启
slow_query_log=1/ON
# 慢查询的超时时间,单位为秒
long_query_time=10
# 慢查询日志文件地址
slow_query_log_file=/usr/local/mysql/sql_log/slow-mysql.log
# 记录所有未使用索引的查询到日志中
log_queries_not_using_indexes=ON
log_slow_admin_statements=OFF
log_slow_slave_statements=OFF
log_throttle_queries_not_using_indexes=10


completion_type=NO_CHAIN
concurrent_insert=AUTO
connect_timeout=10
core_file=OFF

# 数据存放目录
datadir=/usr/local/mysql/data/
date_format=%Y-%m-%d
datetime_format=%Y-%m-%d %H:%i:%s
# 数据库默认引擎类型,默认InnoDB
default_storage_engine=InnoDB
default_tmp_storage_engine=InnoDB
default_week_format=0
delay_key_write=ON
delayed_insert_limit=100
delayed_insert_timeout=300
delayed_queue_size=1000
disconnect_on_expired_password=ON
div_precision_increment=4

end_markers_in_json	OFF
enforce_gtid_consistency=ON
eq_range_index_dive_limit=10
event_scheduler=OFF
# 保留binlog日志的天数,一般一个星期
expire_logs_days=7
explicit_defaults_for_timestamp=OFF
flush=OFF
flush_time=0
foreign_key_checks=ON
ft_boolean_syntax=+ -><()~*:""&|
ft_max_word_len=84
ft_min_word_len=4
ft_query_expansion_limit=20
ft_stopword_file=(built-in)

# 是否开启全局日志
general_log=OFF
# 全局日志日志
general_log_file=/usr/local/mysql/data/localhost.log
group_concat_max_len=1024
gtid_executed=98c4c03e-d495-11e5-b7c0-080027ca20fd:1-15156
# 是否开启gtid复制
gtid_mode=ON
gtid_owned
gtid_purged

have_compress=YES
have_crypt=YES
have_dynamic_loading=YES
have_geometry=YES
have_openssl=DISABLED
have_profiling=YES
have_query_cache=YES
have_rtree_keys=YES
have_ssl=DISABLED
have_symlink=YES
host_cache_size=328
hostname=localhost.localdomain

ignore_builtin_innodb=OFF
ignore_db_dirs
# 初始化数据库链接时提供的配置信息
init_connect
init_file
init_slave
innodb_adaptive_flushing=ON
innodb_adaptive_flushing_lwm=10
innodb_adaptive_hash_index=ON
innodb_adaptive_max_sleep_delay=150000
# 定义innodb的数据字典和内部数据结构的缓冲池大小.当数据库对象非常多时,适当调整该参数的大小以确保所有数据都能存放在内存中提高访问效率,当过小时,MySQL会记录Warning信息到数据库的错误日志中,这时就需要该调整这个参数大小
innodb_additional_mem_pool_size=8388608
innodb_api_bk_commit_interval=5
innodb_api_disable_rowlock=OFF
innodb_api_enable_binlog=OFF
innodb_api_enable_mdl=OFF
innodb_api_trx_level=0
innodb_autoextend_increment=64
innodb_autoinc_lock_mode=1
innodb_buffer_pool_dump_at_shutdown=OFF
innodb_buffer_pool_dump_now=OFF
innodb_buffer_pool_filename=ib_buffer_pool
innodb_buffer_pool_instances=8
innodb_buffer_pool_load_abort=OFF
innodb_buffer_pool_load_at_startup=OFF
innodb_buffer_pool_load_now=OFF
# innodb数据,索引等缓存,一般配置为内存的1/3到1/2
innodb_buffer_pool_size=134217728
innodb_change_buffer_max_size=25
innodb_change_buffering=all
innodb_checksum_algorithm=innodb
innodb_checksums=ON
innodb_cmp_per_index_enabled=OFF
innodb_commit_concurrency=0
innodb_compression_failure_threshold_pct=5
innodb_compression_level=6
innodb_compression_pad_pct_max=50
innodb_concurrency_tickets=5000
innodb_data_file_path=ibdata1:128M:autoextend
innodb_data_home_dir
innodb_disable_sort_file_cache=OFF
# 是否开启双写缓存,避免数据损坏
innodb_doublewrite=ON
innodb_fast_shutdown=1
innodb_file_format=Antelope
innodb_file_format_check=ON
innodb_file_format_max=Antelope
# 文件的io线程数
innodb_file_io_threads = 4
# 每个表是否设置一个独立的表空间,最好开启
innodb_file_per_table=ON
innodb_flush_log_at_timeout=1
# 日志刷新到硬盘上的模式:0,每秒写入一次到缓存,同时写入到磁盘,可能会丢失1秒数据
# 1,默认,每次事务都将事务日志写到缓存,同时写入到磁盘,不会丢失数据,但是太影响性能
# 2,建议,每次提交把事务日志写入到缓存,每秒执行一次将缓存写入到磁盘,除非服务器宕机,可能会丢失1秒数据
innodb_flush_log_at_trx_commit=2
# 设置如何跟文件系统交互
innodb_flush_method=O_DIRECT
innodb_flush_neighbors=1
innodb_flushing_avg_loops=30
innodb_force_load_corrupted=OFF
innodb_force_recovery=0
innodb_ft_aux_table
innodb_ft_cache_size=8000000
innodb_ft_enable_diag_print=OFF
innodb_ft_enable_stopword=ON
innodb_ft_max_token_size=84
innodb_ft_min_token_size=3
innodb_ft_num_word_optimize=2000
innodb_ft_result_cache_limit=2000000000
innodb_ft_server_stopword_table
innodb_ft_sort_pll_degree=2
innodb_ft_total_cache_size=640000000
innodb_ft_user_stopword_table
innodb_io_capacity=20000
innodb_io_capacity_max=40000
innodb_large_prefix=OFF
innodb_lock_wait_timeout=60
innodb_locks_unsafe_for_binlog=OFF
 # 事务日志缓冲区大小,不需要很大
innodb_log_buffer_size=16777216
innodb_log_compressed_pages=ON
# 单个事务日志的大小,即bin.log单个日志大小,根据业务而定
innodb_log_file_size=200M
# 控制事务日志文件的个数
innodb_log_files_in_group=2
innodb_log_group_home_dir=./
innodb_lru_scan_depth=1024
# 设置在缓冲池中保存的最大的脏页数量
innodb_max_dirty_pages_pct=75
innodb_max_dirty_pages_pct_lwm=0
innodb_max_purge_lag=0
innodb_max_purge_lag_delay=0
innodb_mirrored_log_groups=1
innodb_monitor_disable
innodb_monitor_enable
innodb_monitor_reset
innodb_monitor_reset_all
innodb_old_blocks_pct=37
innodb_old_blocks_time=1000
innodb_online_alter_log_max_size=134217728
innodb_open_files=8192
innodb_optimize_fulltext_only=OFF
innodb_page_size=16384
innodb_print_all_deadlocks=OFF
innodb_purge_batch_size=300
innodb_purge_threads=1
innodb_random_read_ahead=OFF
innodb_read_ahead_threshold=56
innodb_read_io_threads=8
innodb_read_only=OFF
innodb_replication_delay=0
innodb_rollback_on_timeout=OFF
innodb_rollback_segments=128
innodb_sort_buffer_size=1048576
innodb_spin_wait_delay=6
innodb_stats_auto_recalc=ON
innodb_stats_method=nulls_equal
innodb_stats_on_metadata=OFF
innodb_stats_persistent=ON
innodb_stats_persistent_sample_pages=20
innodb_stats_sample_pages=8
innodb_stats_transient_sample_pages=8
innodb_status_output=OFF
innodb_status_output_locks=OFF
# 定义一个专门为innodb插件提供的服务器sql模式级别
innodb_strict_mode=OFF
innodb_support_xa=ON
innodb_sync_array_size=1
innodb_sync_spin_loops=30
innodb_table_locks=ON
# 线程并发情况,设为CPU核数的2倍
innodb_thread_concurrency=0
innodb_thread_sleep_delay=10000
innodb_undo_directory=.
innodb_undo_logs=128
innodb_undo_tablespaces=0
innodb_use_native_aio=OFF
innodb_use_sys_malloc=ON
innodb_version=5.7.25
innodb_write_io_threads=24
# 超过多长时间没有写入数据就断开连接,单位s
interactive_timeout=18800

# 每个线程联表缓存大小,一次性指定,每张关联会分配一个,多表时同样可能造成内存溢出
join_buffer_size=128M

keep_files_on_create=OFF
# 为MyISAM数据库的索引设置缓冲区大小,使用时才真正分配
key_buffer_size=32M
key_cache_age_threshold=300
key_cache_block_size=1024
key_cache_division_limit=100

large_files_support=ON
large_page_size=0
large_pages=OFF
lc_messages=en_US
lc_messages_dir=/usr/local/mysql/share/
lc_time_names=en_US
license=GPL
local_infile=ON
lock_wait_timeout=31536000
locked_in_memory=OFF
log_error=/usr/local/mysql/sql_log/mysql-error.log
log_output=FILE
# 若是从库也开启binlog日志,做其他从库的主库(级联),或者做备份,需要开启下面的参数
log_slave_updates=ON
log_warnings=2
low_priority_updates=OFF
lower_case_file_system=OFF
lower_case_table_names=0

master_info_repository=TABLE
master_verify_checksum=OFF
# 结果集的最大容量
max_allowed_packet=32M
max_binlog_cache_size=18446744073709547520
max_binlog_size=1048576000
max_binlog_stmt_cache_size=18446744073709547520
# 单次连接最大可能出现的错误数
max_connect_errors=1000000
# 最大客户端连接数
max_connections=200
max_delayed_threads=20
max_digest_length=1024
max_error_count=64
# 定义一个Memory引擎表的最大容量,该参数和tmp_table_size最好大小相同
max_heap_table_size=33554432
max_insert_delayed_threads=20
max_join_size=18446744073709551615
# 用于排序数据的最大长度,可以影响mysql选择那个排序算法
max_length_for_sort_data=16384
max_prepared_stmt_count=16382
max_relay_log_size=0
max_seeks_for_key=18446744073709551615
max_sort_length=1024
max_sp_recursion_depth=0
max_tmp_tables=32
# 用户最大连接数,默认为0无上限
max_user_connections=0
max_write_lock_count=18446744073709551615
metadata_locks_cache_size=1024
metadata_locks_hash_instances=8
min_examined_row_limit=0
multi_range_count=256
myisam_data_pointer_size=6
myisam_max_sort_file_size=9223372036853727232
myisam_mmap_size=18446744073709551615
myisam_recover_options=BACKUP,FORCE
myisam_repair_threads=1
myisam_sort_buffer_size=8388608
myisam_stats_method=nulls_unequal
myisam_use_mmap=OFF

net_buffer_length=16384
net_read_timeout=30
net_retry_count=10
net_write_timeout=60
new=OFF

old=OFF
old_alter_table=OFF
old_passwords=0
open_files_limit=65535
optimizer_prune_level=1
optimizer_search_depth=62
# 设置mysql优化器中那个高级索引合并功能被开启
optimizer_switch=index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,engine_condition_pushdown=on,index_condition_pushdown=on,mrr=on,mrr_cost_based=on,block_nested_loop=on,batched_key_access=off,materialization=on,semijoin=on,loosescan=on,firstmatch=on,subquery_materialization_cost_based=on,use_index_extensions=on
optimizer_trace=enabled=off,one_line=off
optimizer_trace_features=greedy_search=on,range_optimizer=on,dynamic_range=on,repeated_subselect=on
optimizer_trace_limit=1
optimizer_trace_max_mem_size=16384
optimizer_trace_offset=-1

performance_schema=ON
performance_schema_accounts_size=100
performance_schema_digests_size=10000
performance_schema_events_stages_history_long_size=10000
performance_schema_events_stages_history_size=10
performance_schema_events_statements_history_long_size=10000
performance_schema_events_statements_history_size=10
performance_schema_events_waits_history_long_size=10000
performance_schema_events_waits_history_size=10
performance_schema_hosts_size=100
performance_schema_max_cond_classes=80
performance_schema_max_cond_instances=9092
performance_schema_max_file_classes=50
performance_schema_max_file_handles=32768
performance_schema_max_file_instances=100824
performance_schema_max_mutex_classes=200
performance_schema_max_mutex_instances=43160
performance_schema_max_rwlock_classes=40
performance_schema_max_rwlock_instances=25376
performance_schema_max_socket_classes=10
performance_schema_max_socket_instances=420
performance_schema_max_stage_classes=150
performance_schema_max_statement_classes=168
performance_schema_max_table_handles=8192
performance_schema_max_table_instances=12500
performance_schema_max_thread_classes=50
performance_schema_max_thread_instances=500
performance_schema_session_connect_attrs_size=512
performance_schema_setup_actors_size=100
performance_schema_setup_objects_size=100
performance_schema_users_size=100
# mysql运行时的PID文件
pid_file=/usr/local/mysql/data/mysqld.pid
# mysql插件目录
plugin_dir=/usr/local/mysql/lib/plugin/
# socket访问端口
port=3306
preload_buffer_size=32768
profiling=OFF
profiling_history_size=15
protocol_version=10

query_alloc_block_size=8192
query_cache_limit=1048576
query_cache_min_res_unit=4096
# 设置查询缓存大小
query_cache_size=0
query_cache_type=OFF
query_cache_wlock_invalidate=OFF
query_prealloc_size=8192

range_alloc_block_size=4096
# 对表进行顺序扫描的请求将分配一个读入缓冲区,MySql会为它分配一段内存缓冲区.如果对表的顺序扫描请求非常频繁.可以通过增加该变量值以及内存缓冲区大小提高其性能
read_buffer_size=2097152
# 不需要值,只要该参数存在于配置文件中,表示当前数据库只读,不能写.不写默认关闭,可读写
read_only=OFF
# 每个线程查询时索引缓存大小,只会分配需要的内存大小
read_rnd_buffer_size=2097152
relay_log=/usr/local/mysql/sql_log/mysqld-relay-bin
relay_log_basename=/usr/local/mysql/sql_log/mysqld-relay-bin
relay_log_index=/usr/local/mysql/sql_log/mysqld-relay-bin.index
relay_log_info_file=relay-log.info
relay_log_info_repository=TABLE
relay_log_purge=ON
relay_log_recovery=OFF
relay_log_space_limit=0
# 主从开启时从库的设置
# 设定需要复制的数据库,多个用逗号隔开
replication_do_db
# 设定忽略复制的数据库,多个用逗号隔开
replication_ignore_db
# 设定需要复制的表,多个用逗号隔开
replication_do_table
# 设定需要忽略复制的表,多个用逗号隔开
replication_ignore_table
# 同replication-do-table功能一样,但可以加通配符
replication_wild_do_table
# 同replication-ignore-table功能一样,但可以加通配符
replication_wild_ignore_table
report_host
report_password
report_port=3306
report_user
rpl_stop_slave_timeout=31536000

secure_auth=ON
secure_file_priv
# 服务器唯一标识
server_id=1
server_id_bits=32
server_uuid=98c4c03e-d495-11e5-b7c0-080027ca20fd
show_old_temporals=OFF
simplified_binlog_gtid_recovery=OFF
skip_external_locking=ON
# 忽略名字解析,DNS查找,不加可能导致权限错误,但是最好禁用
skip_name_resolve=ON
skip_networking=OFF
skip_show_database=OFF
slave_allow_batching=OFF
slave_checkpoint_group=512
slave_checkpoint_period=300
slave_compressed_protocol=OFF
slave_exec_mode=STRICT
slave_load_tmpdir=/tmp
slave_max_allowed_packet=1073741824
slave_net_timeout=3600
slave_parallel_workers=0
slave_pending_jobs_size_max=16777216
slave_rows_search_algorithms=TABLE_SCAN,INDEX_SCAN
# 主从复制时,忽略符合错误码的错误,1032,1062是错误码
slave_skip_errors=OFF
slave_sql_verify_checksum=ON
slave_transaction_retries=10
slave_type_conversions
slow_launch_time=2
socket=/usr/local/mysql/data/mysql.sock
# 每个线程排序缓存大小.使用的时候才分配,而且是一次性指定,每个表会分配一个,多表同时排序可能会造成内存溢出
sort_buffer_size=32M
sql_auto_is_null=OFF
sql_big_selects=ON
sql_buffer_result=OFF
# 临时不记录binlog
sql_log_off=OFF
# 支持的各种服务器sql模式
# strict_trans_tables:如果给定的事务数据不能插入到事务类型数据库中,则中断操作,在非事务数据库无效
# no_engine_subtitution:若create table所指定的引擎无效,不会使用默认引擎建表
# no_zero_date:不接受日期为0的日期
# no_zero_in_date:在严格模式下,不接受部分日期为0的日期
# only_full_group_by:select的字段必须在group子句中出现
sql_mode=STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION
sql_notes=ON
sql_quote_show_create=ON
sql_safe_updates=OFF
sql_select_limit=18446744073709551615
sql_slave_skip_counter=0
sql_warnings=OFF
ssl_ca
ssl_capath
ssl_cert
ssl_cipher
ssl_crl
ssl_crlpath
ssl_key
storage_engine=InnoDB
stored_program_cache=256
# 控制mysql如何向磁盘刷新binlog
# 0:默认值,表示不主动刷新cache到磁盘,而是由操作系统自己决定
# 大于0:2次写入到磁盘的间隔不超过binlog的多少次写操作,写1最好.若开启主从同步,该配置要开启
sync_binlog=1
sync_frm=ON
sync_master_info=10000
sync_relay_log=10000
sync_relay_log_info=10000
# 确保sysdate()返回日期和now()的结果是一样的
sysdate_is_now
system_time_zone=CST

# 缓存表的大小
table_cache_size
table_definition_cache=4096
table_open_cache=4096
table_open_cache_instances=1
# 线程缓存大小
thread_cache_size=2048
thread_concurrency=24
thread_handling=one-thread-per-connection
thread_stack=524288
time_format=%H:%i:%s
time_zone=SYSTEM
timed_mutexes=OFF
# Memory引擎临时文件表的大小
tmp_table_size=72M
tmpdir=/tmp
transaction_alloc_block_size=8192
transaction_prealloc_size=4096
tx_isolation=REPEATABLE-READ
tx_read_only=OFF

unique_checks=ON
updatable_views_with_limit=YES

version=5.7.25-log
version_comment=Source distribution
version_compile_machine=x86_64
version_compile_os=Linux

# 数据库连接闲置时间,闲置连接会占用内存资源
wait_timeout=18800

[mysqld_safe]
# 错误日志,默认是关闭的
log-error=/app/mysql/logs/mysql-error.log
```








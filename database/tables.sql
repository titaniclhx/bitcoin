
-- 买入表
drop table if exists order_buy;
create table order_buy (mobile bigint,price decimal(10,3),amount  bigint,order_time datetime(6));
-- 卖出表
drop table if exists order_sell;
create table order_sell(mobile bigint,price decimal(10,3),amount bigint,order_time datetime(6));

-- 用户表
drop table if exists users;
create table users(id int auto_increment primary key,mobile bigint,name varchar(12),identity varchar(20),password_hash varchar(128),role_id int);
-- 持仓表
drop table if exists holding;
create table holding(id int auto_increment primary key,mobile bigint,amount int,amount_free int,price decimal(8,2));
-- 成交表
drop table if exists trade;
create table trade 
(id int auto_increment primary key,mobile bigint,amount int,price decimal(8,2),fee decimal(8,2),trade_type TINYINT,trade_time datetime(6));




call p_trade_buy(13501537141,5,5,1)

drop procedure p_trade_buy;

delimiter //
create procedure p_trade_buy()
begin 
	
	declare sell_mobile bigint;
	declare sell_price decimal(8,2);
	declare sell_amount int;
	declare sell_order_time datetime(6);
	
	declare buy_mobile bigint;
	declare buy_price decimal(8,2);
	declare buy_amount int;
	declare buy_order_time datetime(6);
	
	declare amount_tmp int default p_amount;
	--------
	DECLARE cursor_null INTEGER DEFAULT 0;
	DECLARE sql_error INTEGER DEFAULT 0;
	--------
	drop table if exists trade_temp;
	create table trade_temp
	as 
	select	 a.price      as price_sell
			,a.order_time as order_time_sell
			,a.amount     as amount_sell
			,a.mobile     as mobile_sell
			,a.amount     as amount_sell_left
			,0 as amount_trade			
			,b.price      as price_buy 
			,b.order_time as order_time_buy
			,b.amount     as amount_buy 
			,b.mobile     as mobile_buy 
			,b.amount     as amount_buy_left
	from order_sell a 
	join order_buy  b on a.price<=b.price;
	

	drop table if exists v_trade;
	create table v_trade
	as 
	select a.mobile_sell,a.price_sell,a.amount_sell,a.order_time_sell
		,case when a.amount_sell_left>=@amount_buy then a.amount_sell_left-@amount_buy
				else 0 end as amount_sell_left
		,case when a.amount_sell_left>=@amount_buy then amount_trade+@amount_buy
				else amount_trade+a.amount_sell_left end as amount_trade
		,case when a.amount_sell_left>=@amount_buy then @amount_buy:=0
				else @amount_buy:=@amount_buy-a.amount_sell_left end as amount_buy_left
	from (
			select mobile_sell,price_sell,amount_sell,amount_trade,amount_sell_left,order_time_sell 
			from trade_temp where price_sell<=v_price_buy and amount_sell_left>0
			order by price_sell,order_time_sell
		 ) a,(select @amount_buy:=v_amount_buy) b;

	update order_sell_temp a
	join v_trade b on a.price_sell=b.price_sell and a.order_time_sell=b.order_time_sell and a.mobile_sell=b.mobile_sell
	set a.amount_trade=b.amount_trade,a.amount_sell_left=b.amount_sell_left;
	
	update order_buy_temp a
	join (select sum(amount_trade) as amount_trade from v_trade) b on 1=1
	where a.price_buy=v_price_sell and a.order_time_sell=v_order_time_sell and v_mobile_sell=v_mobile_sell
	
	
	--=======================================
	
	
	select   a.price_sell
			,a.order_time_sell
			,a.amount_sell
			,a.mobile_sell
			,a.amount_sell_left
			,case when @amount_sell_left=-1 and a.amount_sell<=a.amount_buy then a.amount_sell
				  when @amount_sell_left=-1 and a.amount_sell> a.amount_buy then a.amount_buy
				  when @amount_sell_left>-1 and @amount_sell_left<=a.amount_buy then @amount_sell_left
				  when @amount_sell_left>-1 and @amount_sell_left> a.amount_buy then a.amount_buy
			
			then a.amount_trade -- ========
			,a.price_buy
			,a.order_time_buy
			,a.amount_buy
			,a.mobile_buy
			,a.amount_buy_left
	from (select * from trade_temp order by price_sell,order_time_sell,price_buy desc,order_time_buy)a,
		 (select @price_sell:=null,@amount_sell_left:=-1) b;
	
	
	--=======================================
	
	
	DECLARE CURSOR_buy CURSOR FOR 
	SELECT mobile,price,amount 
	FROM order_sell 
	where price<=p_price order by price,order_time;

	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_error=1;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET cursor_null = 1;	
	
	open CURSOR_buy;

	start transaction;
	read_loop: loop
		FETCH CURSOR_buy INTO v_mobile,v_price,v_amount;
		if cursor_null or amount_tmp=0 then 
			LEAVE read_loop; 
		end if;
		if amount_tmp<v_amount then
			update order_sell set amount=v_amount-amount_tmp where mobile=v_mobile and price=v_price;
			select sleep(10);
			insert into trade(mobile,amount,price,fee,trade_type,trade_time) 
			values (p_mobile,amount_tmp,v_price,0,1,now(6)),(v_mobile,amount_tmp,v_price,0,0,now(6));
			set amount_tmp=0;
		elseif amount_tmp>v_amount then
			delete from order_sell where mobile=v_mobile and price=v_price;
			insert into trade(mobile,amount,price,fee,trade_type,trade_time) 
			values (p_mobile,v_amount,v_price,0,1,now(6)),(v_mobile,v_amount,v_price,0,0,now(6));
			set amount_tmp=amount_tmp-v_amount;
		else
			delete from order_sell where mobile=v_mobile and price=v_price;
			insert into trade(mobile,amount,price,fee,trade_type,trade_time) 
			values (p_mobile,v_amount,v_price,0,1,now(6)),(v_mobile,v_amount,v_price,0,0,now(6));
			set amount_tmp=0;
		end if;
	end loop;
	
	if sql_error then 
		rollback;
	else 
		commit;
	end if;
	
	close CURSOR_buy;

end
//





/*
call p_trade_buy(13501537141,5,5,1)

drop procedure p_trade_buy;

delimiter //
create procedure p_trade_buy(p_mobile bigint,p_price decimal(8,2),p_amount int,trade_type TINYINT)
begin 
	
	declare v_mobile bigint;
	declare v_price decimal(8,2);
	declare v_amount int;
	declare amount_tmp int default p_amount;
	DECLARE cursor_null INTEGER DEFAULT 0;
	DECLARE sql_error INTEGER DEFAULT 0;
	
	DECLARE CURSOR_buy CURSOR FOR SELECT mobile,price,amount FROM order_sell where price<=p_price order by price,order_time;

	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_error=1;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET cursor_null = 1;	
	
	open CURSOR_buy;

	start transaction;
	read_loop: loop
		FETCH CURSOR_buy INTO v_mobile,v_price,v_amount;
		if cursor_null or amount_tmp=0 then 
			LEAVE read_loop; 
		end if;
		if amount_tmp<v_amount then
			update order_sell set amount=v_amount-amount_tmp where mobile=v_mobile and price=v_price;
			select sleep(10);
			insert into trade(mobile,amount,price,fee,trade_type,trade_time) 
			values (p_mobile,amount_tmp,v_price,0,1,now(6)),(v_mobile,amount_tmp,v_price,0,0,now(6));
			set amount_tmp=0;
		elseif amount_tmp>v_amount then
			delete from order_sell where mobile=v_mobile and price=v_price;
			insert into trade(mobile,amount,price,fee,trade_type,trade_time) 
			values (p_mobile,v_amount,v_price,0,1,now(6)),(v_mobile,v_amount,v_price,0,0,now(6));
			set amount_tmp=amount_tmp-v_amount;
		else
			delete from order_sell where mobile=v_mobile and price=v_price;
			insert into trade(mobile,amount,price,fee,trade_type,trade_time) 
			values (p_mobile,v_amount,v_price,0,1,now(6)),(v_mobile,v_amount,v_price,0,0,now(6));
			set amount_tmp=0;
		end if;
	end loop;
	
	if sql_error then 
		rollback;
	else 
		commit;
	end if;
	
	close CURSOR_buy;

end
//
*/


	
	/*
	FETCH CURSOR_buy INTO v_mobile,v_price,v_amount;
	if not cursor_null then
	
		while amount_tmp>0 and not cursor_null do
			
			if amount_tmp<v_amount then
				update order_sell set amount=v_amount-amount_tmp where mobile=v_mobile and price=v_price;
				insert into trade(mobile,amount,price,fee,trade_type,trade_time) 
				values (p_mobile,amount_tmp,v_price,0,1,now(6)),(v_mobile,amount_tmp,v_price,0,0,now(6));
				set amount_tmp=0;
			elseif amount_tmp>v_amount then
				delete from order_sell where mobile=v_mobile and price=v_price;
				insert into trade(mobile,amount,price,fee,trade_type,trade_time) 
				values (p_mobile,v_amount,v_price,0,1,now(6)),(v_mobile,v_amount,v_price,0,0,now(6));
				set amount_tmp=amount_tmp-v_amount;
			else
				delete from order_sell where mobile=v_mobile and price=v_price;
				insert into trade(mobile,amount,price,fee,trade_type,trade_time) 
				values (p_mobile,v_amount,v_price,0,1,now(6)),(v_mobile,v_amount,v_price,0,0,now(6));
				set amount_tmp=0;
			end if;
			FETCH CURSOR_buy INTO v_mobile,v_price,v_amount;
		end while;

	end if;
	*/


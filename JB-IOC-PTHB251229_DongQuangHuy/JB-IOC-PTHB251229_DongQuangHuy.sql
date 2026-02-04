--Phần 1: Thao tác với dữ liệu bảng
--Bảng Customer

create table Customer (
    customer_id varchar(5) primary key,
    customer_full_name varchar(100) not null,
    customer_email varchar(100) not null unique,
    customer_phone varchar(15) not null,
    customer_address varchar(255) not null
);

insert into Customer values
('C001', 'Nguyen Anh Tu', 'tu.nguyen@example.com', '0912345678', 'Hanoi, Vietnam'),
('C002', 'Tran Thi Mai', 'mai.tran@example.com', '0923456789', 'Ho Chi Minh, Vietnam'),
('C003', 'Le Minh Hoang', 'hoang.le@example.com', '0934567890', 'Danang, Vietnam'),
('C004', 'Pham Hoang Nam', 'nam.pham@example.com', '0945678901', 'Hue, Vietnam'),
('C005', 'Vu Minh Thu', 'thu.vu@example.com', '0956789012', 'Hai Phong, Vietnam');

--Bảng Room

create table Room (
    room_id varchar(5) primary key,
    room_type varchar(50) not null,
    room_price decimal(10,2) not null,
    room_status varchar(20) not null,
    room_area int not null
);

insert into Room (room_id, room_type, room_price, room_status, room_area) values
('R001', 'Single', 100.00, 'Available', 25),
('R002', 'Double', 150.00, 'Booked', 40),
('R003', 'Suite', 250.00, 'Available', 60),
('R004', 'Single', 120.00, 'Booked', 30),
('R005', 'Double', 160.00, 'Available', 35);

--Bảng Booking

create table Booking (
    booking_id serial primary key,
    customer_id varchar(5) not null,
    room_id varchar(5) not null,
    check_in_date date not null,
    check_out_date date not null,
    total_amount decimal(10,2),

    constraint fk_booking_customer
        foreign key (customer_id) references Customer(customer_id),

    constraint fk_booking_room
     	foreign key(room_id) references Room(room_id)
);

insert into Booking(customer_id, room_id, check_in_date, check_out_date, total_amount) values
('C001', 'R001', '2025-03-01', '2025-03-05', 400.00),
('C002', 'R002', '2025-03-02', '2025-03-06', 600.00),
('C003', 'R003', '2025-03-03', '2025-03-07', 1000.00),
('C004', 'R004', '2025-03-04', '2025-03-08', 480.00),
('C005', 'R005', '2025-03-05', '2025-03-09', 800.00);

--Bảng Payment
create table Payment (
    payment_id serial primary key,
    booking_id int not null,
    payment_method varchar(50) not null,
    payment_date date not null,
    payment_amount decimal(10,2) not null,

    constraint fk_payment_booking
        foreign key (booking_id) references Booking(booking_id)
);

insert into payment(booking_id, payment_method, payment_date, payment_amount) values
(1, 'Cash', '2025-03-05', 400.00),
(2, 'Credit Card', '2025-03-06', 600.00),
(3, 'Bank Transfer', '2025-03-07', 1000.00),
(4, 'Cash', '2025-03-08', 480.00),
(5, 'Credit Card', '2025-03-09', 800.00);

select * from Customer;
select * from Room;
select * from Booking;
select * from Payment;

/*3. Cập nhật dữ liệu (6 điểm)
Viết câu lệnh UPDATE để cập nhật lại
total_amount trong bảng Booking theo
công thức: total_amount = room_price * (số ngày lưu trú).
- Điều kiện:
  - Chỉ cập nhật cho các phòng có trạng thái (room_status) là "Booked".
  - Chỉ cập nhật khi ngày nhận phòng (check_in_date) đã qua (ví dụ: check_in_date < CURRENT_DATE).*/
update Booking
set total_amount = ((select room_price from Room where room_id = booking.room_id) * (check_out_date - check_in_date ))
where room_id in (select room_id from Room where room_status = 'Booked' and check_in_date < CURRENT_DATE);

--Xóa dữ liệu
delete from Payment
where payment_method = 'Cash' and payment_amount < 500;


--Phần 2: Truy vấn dữ liệu
/*5. (3 điểm) Lấy thông tin khách hàng gồm: mã khách hàng, họ tên, email,
số điện thoại và địa chỉ được sắp xếp theo họ tên khách hàng tăng dần.*/
select customer_id "Mã khách hàng", customer_full_name "Họ tên", customer_email "Email", customer_phone "Số điện thoại", customer_address "Địa chỉ"
from Customer
order by customer_full_name asc;

/*6. (3 điểm) Lấy thông tin các phòng khách sạn gồm: mã phòng, loại phòng, giá phòng và diện
tích phòng, sắp xếp theo giá phòng giảm dần.*/
select room_id "Mã phòng", room_type "Loại phòng", room_price "Giá phòng", room_area "Diện tích"
from Room
order by room_area desc;

/*7. (3 điểm) Lấy thông tin khách hàng và phòng khách sạn đã đặt, gồm mã khách hàng,
họ tên khách hàng, mã phòng, ngày nhận phòng và ngày trả phòng.*/
select c.customer_id "Mã khách hàng",
	   c.customer_full_name "Họ tên khách hàng",
	   b.room_id "Mã phòng",
	   b.check_in_date "Ngày nhận phòng",
	   b.check_out_date "Ngày trả phòng"
from customer c join booking b on c.customer_id = b.customer_id;

/*8. (3 điểm) Lấy danh sách khách hàng và tổng tiền đã thanh toán khi đặt phòng, gồm mã khách
hàng, họ tên khách hàng, phương thức thanh toán và số tiền thanh toán, sắp xếp theo số tiền
thanh toán giảm dần.*/
select c.customer_id "Mã khách hàng",
	   c.customer_full_name "Họ tên khách hàng",
	   p.payment_method "Phương thức thanh toán",
	   p.payment_amount "số tiền thanh toán"
from customer c
	join booking b on c.customer_id = b.customer_id 
	join payment p on b.booking_id = p.booking_id
order by p.payment_amount desc;

/*9. (3 điểm) Lấy tất cả thông tin khách hàng từ vị trí thứ 2 đến thứ 4 trong bảng Customer được
sắp xếp theo tên khách hàng.*/
select * 
from customer
order by customer_full_name desc
limit 3 offset 1;

/*10. (5 điểm) Lấy danh sách khách hàng đã đặt ít nhất 2 phòng và có tổng số tiền thanh toán trên 1000,
gồm mã khách hàng, họ tên khách hàng và số lượng phòng đã đặt*/
select c.customer_id "Mã khách hàng",
	   c.customer_full_name "Tên khách hàng",
	   count(*)"Số lượng phòng đã đặt"
from customer c
join booking b on c.customer_id = b.customer_id
join payment p on b.booking_id = p.booking_id
group by c.customer_id, c.customer_full_name
having count(*) >=2 and sum(p.payment_amount) > 1000;

/*11. (5 điểm) Lấy danh sách các phòng có tổng số tiền thanh toán dưới 1000 và có ít nhất 3 khách hàng đặt, gồm mã phòng,
loại phòng, giá phòng và tổng số tiền thanh toán.*/
select r.room_id "Mã phòng",
	   r.room_type "Loại phòng",
	   r.room_price "Giá phòng",
	   sum(p.payment_amount) "Tổng số tiền thanh toán"
from Room r
left join Booking b on r.room_id = b.room_id
left join Payment p on b.booking_id = p.booking_id
group by r.room_id, r.room_type, r.room_price
having count(p.booking_id) >= 3 and sum(p.payment_amount) < 1000;

/*12. (5 điểm) Lấy danh sách các khách hàng có tổng số tiền đã thanh toán lớn hơn 1000, gồm mã
khách hàng, họ tên khách hàng, mã phòng, tổng số tiền đã thanh toán.*/
select c.customer_id "Mã khách hàng",
	   c.customer_full_name "Hộ tên khách hàng",
	   b.room_id "Mã phòng",
	   sum(p.payment_amount) "Tổng số tiền thanh toán"
from customer c
join booking b on c.customer_id = b.customer_id
join payment p on b.booking_id = p.booking_id
group by c.customer_id, c.customer_full_name, b.room_id
having sum(p.payment_amount) > 1000;

/*13. (6 điểm) Lấy danh sách các khách hàng gồm : mã KH, Họ tên, email, sđt có họ tên chứa chữ
"Minh" hoặc địa chỉ ở "Hanoi". Sắp xếp kết quả theo họ tên tăng dần.*/
select customer_id "Mã KH",
	   customer_full_name "Họ tên",
	   customer_email "Email",
	   customer_phone "Số điện thoại"
from customer
where customer_full_name like '%Minh%' or customer_address ilike '%Hanoi&'
order by customer_full_name asc;

/*14. (4 điểm)  Lấy danh sách tất cả các phòng (Mã phòng, Loại phòng, Giá), sắp xếp theo giá phòng giảm dần.
Hiển thị 5 phòng tiếp theo sau 5 phòng đầu tiên (tức là lấy kết quả của trang thứ 2, biết mỗi trang có 5 phòng).*/
select room_id "Mã phòng",
	   room_type "Loại phòng", 
	   room_price "Giá"
from room
order by room_price desc
limit 5 offset 5;


--Phần 3: Tạo View
/*15. (5 điểm) Hãy tạo một view để lấy thông tin các phòng và khách hàng đã đặt, với điều kiện
ngày nhận phòng nhỏ hơn ngày 2025-03-10. Cần hiển thị các thông tin sau: Mã phòng, Loại
phòng, Mã khách hàng, họ tên khách hàng*/
create view v_information as
select r.room_id,
	   r.room_price,
	   c.customer_id,
	   c.customer_full_name
from customer c 
join booking b on c.customer_id = b.customer_id
join room r on b.room_id = r.room_id
where b.check_in_date < '2025-03-10'; 

/*16. (5 điểm) Hãy tạo một view để lấy thông tin khách hàng và phòng đã đặt, với điều kiện diện
tích phòng lớn hơn 30 m². Cần hiển thị các thông tin sau: Mã khách hàng, Họ tên khách
hàng, Mã phòng, Diện tích phòng*/
create view v_area as
select c.customer_id,
	   c.customer_full_name,
	   r.room_id,
	   r.room_area
from customer c 
join booking b on c.customer_id = b.customer_id
join room r on b.room_id = r.room_id
where r.room_area > 30;

/*17. (5 điểm) Hãy tạo một trigger check_insert_booking để kiểm tra dữ liệu mối khi chèn vào
bảng Booking. Kiểm tra nếu ngày đặt phòng mà sau ngày trả phòng thì thông báo lỗi với nội
dung “Ngày đặt phòng không thể sau ngày trả phòng được !” và hủy thao tác chèn dữ liệu
vào bảng.*/
create or replace function f_check_insert_booking()
returns trigger
language plpgsql
as $$
begin
	if new.check_in_date < new.check_out_date then
	raise exception 'Ngày đặt phòng không thể sau ngày trả phòng được!';
	end if;
	return new;
end;
$$;

create trigger check_insert_booking
before insert on booking
for each row 
execute function f_check_insert_booking();

/*18. (5 điểm) Hãy tạo một trigger có tên là update_room_status_on_booking
để tự động cập nhật trạng thái phòng thành "Booked" khi một phòng được đặt
(khi có bản ghi được INSERT vào bảng Booking).*/
create or replace function f_update_room_status_on_booking()
returns trigger
language plpgsql
as $$
begin
	update Room
	set room_status = 'Booked'
	where room_id = new.room_id;
	return new;
end;
$$;

create trigger update_room_status_on_booking
after insert on Booking
for each row
execute function f_update_room_status_on_booking();


--Test:
select * from Room;
insert into Booking(customer_id, room_id, check_in_date, check_out_date, total_amount) values
('C001', 'R004', '2025-03-01', '2025-03-05', 400.00),
('C002', 'R005', '2025-03-02', '2025-03-06', 600.00);


--Phần 5: Tạo Stored Procedure
/*19. (5 điểm) Viết store procedure có tên add_customer để thêm mới một khách hàng với đầy đủ
các thông tin cần thiết.*/
create or replace procedure add_customer(
	p_id varchar(5),
    p_full_name varchar(100), 
    p_email varchar(100),
    p_phone varchar(15),
    p_address varchar(255)
)
language plpgsql
as $$
begin 
	insert into Customer(customer_id, customer_full_name, customer_email, customer_phone, customer_address) values
	(p_id, p_full_name, p_email, p_phone, p_address);
end;
$$;

--Test 
call add_customer('C0010', 'Nguyen Anh Long', 'long.nguyen@example.com', '0912345678', 'Hanoi, Vietnam');
select * from Customer;

/*20. (5 điểm) Hãy tạo một Stored Procedure  có tên là add_payment
để thực hiện việc thêm một thanh toán mới cho một lần đặt phòng.*/
create or replace procedure add_payment(
    p_booking_id int,
    p_payment_method varchar(50),
    p_payment_date date,
    p_payment_amount decimal(10,2) 
)
language plpgsql
as $$
begin 
	insert into Payment(booking_id, payment_method, payment_date, payment_amount) values
	(p_booking_id, p_payment_method, p_payment_date, p_payment_amount);
end;
$$;

--Test
call add_payment(2, 'Cash', '2025-03-05', 400.00);
select * from Payment;







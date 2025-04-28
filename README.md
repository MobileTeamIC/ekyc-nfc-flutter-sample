# Hướng dẫn sử dụng phiên bản android
Dự án mẫu thực hiện việc tích hợp SDK Đọc thông tin thẻ chip bằng công nghệ NFC cho ứng dụng di động (Android)
## Hướng dẫn cài đặt
## Quan trọng: - Liên hệ với chúng tôi qua trang web: [https://ekyc.vnpt.vn/vi]() hoặc email **vnptai@vnpt.vn** để có thể lấy được các token và sdk, nếu không ứng dụng sẽ không chạy được

### Bước 1: Cài đặt Android Studio
- Tải Android Studio tại [đây](https://developer.android.com/studio)
- Cài đặt Android Studio theo hướng dẫn trên trang web
### Bước 2: Tải mã nguồn
- Tải mã nguồn dự án về máy tính của bạn bằng cách sử dụng lệnh sau trong terminal:
```bash
git clone ...
```
### Bước 3: Mở dự án trong Android Studio
- Mở Android Studio và chọn "Open an existing Android Studio project"
- Chọn thư mục chứa mã nguồn dự án mà bạn đã tải về
- Nếu cần thiết, mở riêng thư mục android trong android studio thay vì mở cả ứng dụng flutter để tiện cho việc cài đặt
- Chờ Android Studio tải các phụ thuộc và cấu hình dự án
- Nếu bạn gặp lỗi về phiên bản Gradle, hãy kiểm tra tệp `gradle-wrapper.properties` trong thư mục `gradle/wrapper` và đảm bảo rằng phiên bản Gradle tương thích với phiên bản Android Studio của bạn
- Thêm sdk vào thư mục tương ứng
- **Lưu ý**: Sử dụng Java 11/17 để build dự án

### Bước 4: Cấu hình thiết bị
- Kết nối thiết bị Android của bạn với máy tính qua cáp USB
- Bật chế độ "USB Debugging" trên thiết bị Android của bạn
- Mở Android Studio và chọn thiết bị của bạn từ danh sách thiết bị ảo hoặc thiết bị thật
- Nếu bạn chưa cài đặt trình điều khiển USB cho thiết bị của mình, hãy làm theo hướng dẫn trên trang web của nhà sản xuất thiết bị để cài đặt trình điều khiển

### Bước 5 (quan trọng): Cấu hình ứng dụng
- Khách hàng sẽ đăng nhập bằng tài khoản trên landing page
- Truy cập vào mục "Quản lý Token ở cột bên trái" và lấy các token cần thiết, để ý hộp thoại nhỏ ở góc trên bên phải màn hình để chọn đúng dịch vụ mình sử dụng
- Thay token vào các giá trị tương ứng trong class MainActivity
- **Chú ý**: AccessToken sẽ sử dụng API để refresh định kì

### Bước 6: Chạy ứng dụng
- Nhấn nút "Run" (hình tam giác màu xanh) trong Android Studio để biên dịch và chạy ứng dụng trên thiết bị của bạn
- Chờ cho ứng dụng được cài đặt và khởi động trên thiết bị
- Khi ứng dụng đã chạy, bạn có thể thử nghiệm các tính năng của nó bằng cách sử dụng NFC trên thiết bị của bạn
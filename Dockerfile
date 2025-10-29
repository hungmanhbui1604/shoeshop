# --- STAGE 1: Build ---
# Sử dụng image Maven chính thức với Java 1.8 (như trong tóm tắt)
FROM maven:3.8.5-openjdk-8-slim AS build

# Đặt thư mục làm việc
WORKDIR /app

# Sao chép tệp pom.xml để tải dependencies (tận dụng cache)
COPY pom.xml .
RUN mvn dependency:go-offline

# Sao chép toàn bộ mã nguồn
COPY src ./src

# Build ứng dụng và đóng gói thành tệp .jar
# Bỏ qua test để build nhanh hơn trong pipeline (giả định test đã chạy ở bước CI khác)
RUN mvn package -DskipTests

# --- STAGE 2: Run ---
#
# DÒNG SỬA LỖI CUỐI CÙNG:
# Sử dụng image OpenJDK 8 JRE Alpine chính thức (chuẩn nhất)
FROM openjdk:8-jre-alpine

WORKDIR /app

# Sao chép tệp .jar đã build từ stage 'build'
# Tên tệp .jar có thể cần được thay đổi cho đúng với project của bạn
# Hãy kiểm tra trong thư mục /target/ của bạn.
COPY --from=build /app/target/shoe-shopping-cart-0.0.1-SNAPSHOT.jar app.jar

# Mở cổng 8080 (cổng mặc định của Spring Boot)
EXPOSE 8080

# Lệnh để chạy ứng dụng
# app.jar sẽ được chạy khi container khởi động
ENTRYPOINT ["java", "-jar", "app.jar"]
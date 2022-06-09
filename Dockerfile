# openjdk 11 sürümünü kullanacağım
FROM openjdk:11

# Tüm dosyaları /app klasörüne kopyalıyorum
COPY . /app

# Çalışma dizinini /app olarak belirliyorum
WORKDIR /app

# İmaj oluşturulurken java derleme işlemi yapmasını sağlıyorum
RUN javac Hello.java

# Konteyner koşmaya başladığı zaman derlenen java kodunu çalıştıracak
CMD ["java","Hello"]
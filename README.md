# infrastructure

![Örnek Resim](https://github.com/Cantooine/infrastructure/blob/master/diagram.png)
## Giriş
Bu repo, AWS üzerinde highly available ve scalable bir web uygulaması altyapısının nasıl kurulabileceğine örnek teşkil etmektedir. Uygulama, frontend ve backend bileşenlerinden oluşmaktadır. Frontend external bir load balancer üzerinden internete açılmış iken, backend bir internal load balancer ile private subnet içerisinden trafik kabul etmektedir.

## Önkoşullar
* AWS Hesabı
* Terraform kurulumu
* AWS CLI kurulumu ve yapılandırılması

## Özet
**VPC ve Subnetler**: Proje için bir VPC (10.0.0.0/16) ve bu VPC'de hem private hem de public subnetler oluşturulur.

**Internet Gateway (IGW) ve NAT Gateway**: Public subnetler için IGW ve private subnetlerin her availablity zone'u için ayrı bir NAT Gateway oluşturulur.

**Route Table'lar**: Public subnetler için bir, private subnetler için AZ sayısı kadar route table tanımlanır. Public subnetler IGW üzerinden internete çıkış yaparken, private subnetler kendi AZ'lerindeki NAT Gateway üzerinden internete çıkış yaparlar. Bu subnetler birbiri ile VPC'nin default route table'ı üzerinden iletişim kurabilmektedir.

**Security Group'lar**: Frontend ve backend ECS servislerinin security group'ları kendi load balancer'larından trafik kabul edecek şekilde ayarlanır. Frontend load balancer'ının security group'u dışardan trafik alabilecek şekilde, backend load balancer'ının security group'u private subnet'ten trafik alabilecek şekilde ayarlanır.

**ECS Cluster, Task Definition ve Service**: Uygulamanın frontend ve backend bileşenleri için bir ECS cluster, task definition'lar ve service'lar oluşturulur.

**Application Load Balancer (ALB)**: Trafik yönlendirme ve yük dengeleme için hem internal (backend için) hem de external (frontend için) ALB'ler oluşturulur. ECS servislerinin target group'ları oluşturulur ve bu load balancer'lara attach edilir.

## Kurmak İçin

`git clone https://github.com/cantooine/infrastructure`

`cd infrastructure`

`terraform init`

`terraform plan`

`terraform apply`

## Silmek İçin

`terraform destroy`

## Detaylar

Subnet CIDR'ları maksimum IP alabilecek şekilde ayarlanmıştır. Bu ileriye dönük scale olma halinde subnette IP kalmaması durumundan korunabilmek içindir.

Her AZ için bir NAT Gateway oluşturulmuştur. Bu yapı AZ'leri birbirinden izole eder ve bir AZ'de sorun olması veya bir AZ'nin route table'ında sorunlu bir konfigürasyon yapılması durumunda, diğer AZ'ler bundan etkilenmez ve internete bağlantıları kesilmez. Bu tercih projeden projeye değişebilmekle birlikte, HA hayati olduğu projelerde en az iki NAT gateway konfigüre etmek önemlidir.

Backend ECS servisi private subnette çalışmakta olduğundan, IP filtering yapan external kaynaklara erişebilmesi için NAT gateway'in dışarı çıkan IP adreslerini ilgili yetkililere beyan etmek yeterli olacaktır.

Frontend, backend ile internal load balancer üzerinden iletişim kurar. Service discovery'e kıyasla bu implementasyonun yük dengeleme, health check ve otomatik yönlendirme gibi bazı avantajları olur. Bu avantajlar HA'ya ve fault tolerance'a katkıda bulunur.

ECS servisleri için autoscaling ayarlanmıştır. Bu scalablity'nin sağlanmasını gözetir. Projenin ihtiyacına göre scaling ayarları Terraform üzerinden yapılandırılabilir.

ECS servisleri FARGATE ile çalıştırılmaktadır. FARGATE, EC2'ya kıyasla cost-effective ve yönetimi kolay bir çözümdür (FARGATE'de kullanılan kadar ödenirken, EC2'da devamlı ödeme gerekmektedir).

Proje PoC niteliğinde olduğundan, doğrudan kullanıma uygun değildir. tfstate dosyasının nerede nasıl saklanacağını ayarlamak, birden fazla kişinin çalıştığı projelerde state lock mekanizması oluşturmak, external ALB için WAF ve SSL yapılandırmaları yapmak önemlidir.

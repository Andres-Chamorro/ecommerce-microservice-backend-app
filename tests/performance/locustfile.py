"""
Pruebas de Rendimiento y Estrés con Locust
Simula casos de uso reales del sistema e-commerce
"""

from locust import HttpUser, task, between, SequentialTaskSet
import random
import json


class UserBehavior(SequentialTaskSet):
    """
    Simula el comportamiento secuencial de un usuario en el sistema
    """
    
    def on_start(self):
        """Se ejecuta cuando un usuario virtual inicia"""
        self.user_id = None
        self.product_id = None
        self.order_id = None
        
    @task(1)
    def register_user(self):
        """Prueba 1: Registro de usuario"""
        user_data = {
            "firstName": f"LoadTest{random.randint(1000, 9999)}",
            "lastName": "User",
            "email": f"loadtest{random.randint(1000, 9999)}@example.com",
            "phone": f"555{random.randint(1000000, 9999999)}"
        }
        
        with self.client.post(
            "/user-service/api/users",
            json=user_data,
            catch_response=True,
            name="Register User"
        ) as response:
            if response.status_code == 200:
                self.user_id = response.json().get("userId")
                response.success()
            else:
                response.failure(f"Failed to register user: {response.status_code}")
    
    @task(2)
    def browse_products(self):
        """Prueba 2: Navegación por catálogo de productos"""
        with self.client.get(
            "/product-service/api/products",
            catch_response=True,
            name="Browse Products"
        ) as response:
            if response.status_code == 200:
                products = response.json().get("collection", [])
                if products:
                    self.product_id = products[0].get("productId")
                response.success()
            else:
                response.failure(f"Failed to browse products: {response.status_code}")
    
    @task(3)
    def view_product_details(self):
        """Prueba 3: Ver detalles de producto"""
        if self.product_id:
            with self.client.get(
                f"/product-service/api/products/{self.product_id}",
                catch_response=True,
                name="View Product Details"
            ) as response:
                if response.status_code == 200:
                    response.success()
                else:
                    response.failure(f"Failed to view product: {response.status_code}")
    
    @task(4)
    def add_to_favourites(self):
        """Prueba 4: Agregar producto a favoritos"""
        if self.user_id and self.product_id:
            favourite_data = {
                "userId": self.user_id,
                "productId": self.product_id,
                "likeDate": "2024-01-15"
            }
            
            with self.client.post(
                "/favourite-service/api/favourites",
                json=favourite_data,
                catch_response=True,
                name="Add to Favourites"
            ) as response:
                if response.status_code == 200:
                    response.success()
                else:
                    response.failure(f"Failed to add favourite: {response.status_code}")
    
    @task(5)
    def create_order(self):
        """Prueba 5: Crear pedido"""
        if self.user_id:
            order_data = {
                "userId": self.user_id,
                "orderDate": "2024-01-15",
                "orderDesc": "Load Test Order",
                "orderFee": round(random.uniform(50.0, 500.0), 2)
            }
            
            with self.client.post(
                "/order-service/api/orders",
                json=order_data,
                catch_response=True,
                name="Create Order"
            ) as response:
                if response.status_code == 200:
                    self.order_id = response.json().get("orderId")
                    response.success()
                else:
                    response.failure(f"Failed to create order: {response.status_code}")
    
    @task(6)
    def process_payment(self):
        """Prueba 6: Procesar pago"""
        if self.order_id:
            payment_data = {
                "orderId": self.order_id,
                "isPayed": True,
                "paymentStatus": "COMPLETED"
            }
            
            with self.client.post(
                "/payment-service/api/payments",
                json=payment_data,
                catch_response=True,
                name="Process Payment"
            ) as response:
                if response.status_code == 200:
                    response.success()
                else:
                    response.failure(f"Failed to process payment: {response.status_code}")
    
    @task(7)
    def create_shipping(self):
        """Prueba 7: Crear envío"""
        if self.order_id:
            shipping_data = {
                "orderId": self.order_id,
                "shippingDate": "2024-01-16",
                "shippingStatus": "PROCESSING"
            }
            
            with self.client.post(
                "/shipping-service/api/shippings",
                json=shipping_data,
                catch_response=True,
                name="Create Shipping"
            ) as response:
                if response.status_code == 200:
                    response.success()
                else:
                    response.failure(f"Failed to create shipping: {response.status_code}")


class ReadOnlyUser(HttpUser):
    """
    Usuario que solo realiza operaciones de lectura (navegación)
    Simula usuarios que solo navegan sin comprar
    """
    wait_time = between(1, 3)
    weight = 3  # 60% de usuarios son de solo lectura
    
    @task(5)
    def browse_products(self):
        """Navegar productos"""
        self.client.get("/product-service/api/products", name="Browse Products (Read-Only)")
    
    @task(3)
    def view_random_product(self):
        """Ver producto aleatorio"""
        product_id = random.randint(1, 100)
        self.client.get(
            f"/product-service/api/products/{product_id}",
            name="View Product (Read-Only)"
        )
    
    @task(2)
    def check_user_profile(self):
        """Ver perfil de usuario"""
        user_id = random.randint(1, 50)
        self.client.get(
            f"/user-service/api/users/{user_id}",
            name="View User Profile (Read-Only)"
        )


class BuyerUser(HttpUser):
    """
    Usuario que realiza compras completas
    Simula el flujo completo de compra
    """
    tasks = [UserBehavior]
    wait_time = between(2, 5)
    weight = 2  # 40% de usuarios realizan compras
    host = "http://localhost:8080"  # API Gateway


class StressTestUser(HttpUser):
    """
    Usuario para pruebas de estrés
    Realiza múltiples operaciones concurrentes
    """
    wait_time = between(0.5, 1.5)
    weight = 1  # Usado solo en pruebas de estrés
    
    @task(10)
    def rapid_product_browsing(self):
        """Navegación rápida de productos"""
        for _ in range(5):
            self.client.get("/product-service/api/products")
    
    @task(5)
    def rapid_user_lookups(self):
        """Búsquedas rápidas de usuarios"""
        for _ in range(3):
            user_id = random.randint(1, 100)
            self.client.get(f"/user-service/api/users/{user_id}")
    
    @task(3)
    def rapid_order_creation(self):
        """Creación rápida de pedidos"""
        order_data = {
            "userId": random.randint(1, 50),
            "orderDate": "2024-01-15",
            "orderDesc": "Stress Test Order",
            "orderFee": round(random.uniform(10.0, 1000.0), 2)
        }
        self.client.post("/order-service/api/orders", json=order_data)


# Configuración de escenarios de prueba
"""
Para ejecutar las pruebas:

1. Prueba de carga normal (simula tráfico real):
   locust -f locustfile.py --users 50 --spawn-rate 5 --run-time 5m

2. Prueba de estrés (alta carga):
   locust -f locustfile.py --users 200 --spawn-rate 20 --run-time 10m

3. Prueba de picos (spike test):
   locust -f locustfile.py --users 500 --spawn-rate 100 --run-time 2m

4. Prueba de resistencia (soak test):
   locust -f locustfile.py --users 100 --spawn-rate 10 --run-time 30m

5. Modo headless (sin interfaz web):
   locust -f locustfile.py --headless --users 100 --spawn-rate 10 --run-time 5m --html report.html
"""

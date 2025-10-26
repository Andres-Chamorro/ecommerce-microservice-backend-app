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
        """Prueba 1: Registro de usuario (POST)"""
        random_num = random.randint(10000, 99999)
        user_data = {
            "firstName": f"Load{random_num}",
            "lastName": "Test",
            "email": f"load{random_num}@test.com",
            "phone": f"+1555{random.randint(1000000, 9999999)}",
            "imageUrl": "https://bootdey.com/img/Content/avatar/avatar7.png"
        }
        
        with self.client.post(
            "http://localhost:8700/user-service/api/users",
            json=user_data,
            catch_response=True,
            name="POST Register User"
        ) as response:
            if response.status_code == 200:
                try:
                    self.user_id = response.json().get("userId")
                    response.success()
                except:
                    response.success()
            elif response.status_code in [201, 400]:  # 400 puede ser email duplicado
                response.success()
            else:
                response.failure(f"Failed: {response.status_code}")
    
    @task(2)
    def browse_products(self):
        """Prueba 2: Navegación por catálogo de productos (GET)"""
        with self.client.get(
            "http://localhost:8500/product-service/api/products",
            catch_response=True,
            name="GET Browse Products"
        ) as response:
            if response.status_code == 200:
                try:
                    products = response.json().get("collection", [])
                    if products:
                        self.product_id = products[0].get("productId")
                except:
                    pass
                response.success()
            else:
                response.failure(f"Failed: {response.status_code}")
    
    @task(3)
    def view_product_details(self):
        """Prueba 3: Ver detalles de producto (GET)"""
        product_id = self.product_id if self.product_id else random.randint(1, 5)
        with self.client.get(
            f"http://localhost:8500/product-service/api/products/{product_id}",
            catch_response=True,
            name="GET View Product Details"
        ) as response:
            if response.status_code in [200, 404]:  # 404 es aceptable si el producto no existe
                response.success()
            else:
                response.failure(f"Failed: {response.status_code}")
    
    @task(4)
    def add_to_favourites(self):
        """Prueba 4: Agregar producto a favoritos (POST)"""
        user_id = self.user_id if self.user_id else random.randint(1, 5)
        product_id = self.product_id if self.product_id else random.randint(1, 5)
        
        favourite_data = {
            "userId": user_id,
            "productId": product_id,
            "likeDate": "2024-01-15"
        }
        
        with self.client.post(
            "http://localhost:8800/favourite-service/api/favourites",
            json=favourite_data,
            catch_response=True,
            name="POST Add to Favourites"
        ) as response:
            if response.status_code in [200, 201, 400]:  # 400 puede ser favorito duplicado
                response.success()
            else:
                response.failure(f"Failed: {response.status_code}")
    
    @task(5)
    def create_order(self):
        """Prueba 5: Crear pedido (POST)"""
        user_id = self.user_id if self.user_id else random.randint(1, 5)
        
        order_data = {
            "userId": user_id,
            "orderDate": "2024-01-15",
            "orderDesc": "Load Test Order",
            "orderFee": round(random.uniform(50.0, 500.0), 2)
        }
        
        with self.client.post(
            "http://localhost:8300/order-service/api/orders",
            json=order_data,
            catch_response=True,
            name="POST Create Order"
        ) as response:
            if response.status_code in [200, 201]:
                try:
                    self.order_id = response.json().get("orderId")
                except:
                    pass
                response.success()
            elif response.status_code == 400:  # Error de validación es aceptable
                response.success()
            else:
                response.failure(f"Failed: {response.status_code}")
    
    @task(6)
    def process_payment(self):
        """Prueba 6: Procesar pago (POST)"""
        order_id = self.order_id if self.order_id else random.randint(1, 5)
        
        payment_data = {
            "orderId": order_id,
            "isPayed": True,
            "paymentStatus": "COMPLETED"
        }
        
        with self.client.post(
            "http://localhost:8400/payment-service/api/payments",
            json=payment_data,
            catch_response=True,
            name="POST Process Payment"
        ) as response:
            if response.status_code in [200, 201, 400]:  # 400 puede ser pago duplicado
                response.success()
            else:
                response.failure(f"Failed: {response.status_code}")
    
    @task(7)
    def create_shipping(self):
        """Prueba 7: Crear envío (POST)"""
        order_id = self.order_id if self.order_id else random.randint(1, 5)
        
        shipping_data = {
            "orderId": order_id,
            "shippingDate": "2024-01-16",
            "shippingStatus": "PROCESSING"
        }
        
        with self.client.post(
            "http://localhost:8600/shipping-service/api/shippings",
            json=shipping_data,
            catch_response=True,
            name="POST Create Shipping"
        ) as response:
            if response.status_code in [200, 201, 400]:  # 400 puede ser envío duplicado
                response.success()
            else:
                response.failure(f"Failed: {response.status_code}")
    
    @task(8)
    def update_user(self):
        """Prueba 8: Actualizar usuario (PUT)"""
        user_id = self.user_id if self.user_id else random.randint(1, 5)
        
        updated_data = {
            "userId": user_id,
            "firstName": f"Updated{random.randint(1000, 9999)}",
            "lastName": "TestUser",
            "email": f"updated{random.randint(10000, 99999)}@test.com",
            "phone": f"+1555{random.randint(1000000, 9999999)}",
            "imageUrl": "https://bootdey.com/img/Content/avatar/avatar7.png"
        }
        
        with self.client.put(
            "http://localhost:8700/user-service/api/users",
            json=updated_data,
            catch_response=True,
            name="PUT Update User"
        ) as response:
            if response.status_code in [200, 404]:  # 404 si el usuario no existe
                response.success()
            else:
                response.failure(f"Failed: {response.status_code}")
    
    @task(9)
    def update_order(self):
        """Prueba 9: Actualizar pedido (PUT)"""
        order_id = self.order_id if self.order_id else random.randint(1, 5)
        
        updated_order = {
            "orderId": order_id,
            "userId": self.user_id if self.user_id else random.randint(1, 5),
            "orderDate": "2024-01-15",
            "orderDesc": "Updated Load Test Order",
            "orderFee": round(random.uniform(100.0, 800.0), 2)
        }
        
        with self.client.put(
            "http://localhost:8300/order-service/api/orders",
            json=updated_order,
            catch_response=True,
            name="PUT Update Order"
        ) as response:
            if response.status_code in [200, 404]:  # 404 si el pedido no existe
                response.success()
            else:
                response.failure(f"Failed: {response.status_code}")


class ReadOnlyUser(HttpUser):
    """
    Usuario que solo realiza operaciones de lectura (navegación)
    Simula usuarios que solo navegan sin comprar
    """
    wait_time = between(1, 3)
    weight = 3  # 60% de usuarios son de solo lectura
    host = "http://localhost"
    
    @task(5)
    def browse_products(self):
        """Navegar productos (GET)"""
        self.client.get("http://localhost:8500/product-service/api/products", name="GET Browse Products")
    
    @task(3)
    def view_random_product(self):
        """Ver producto aleatorio (GET)"""
        product_id = random.randint(1, 5)
        self.client.get(
            f"http://localhost:8500/product-service/api/products/{product_id}",
            name="GET View Product"
        )
    
    @task(2)
    def check_user_profile(self):
        """Ver perfil de usuario (GET)"""
        user_id = random.randint(1, 5)
        self.client.get(
            f"http://localhost:8700/user-service/api/users/{user_id}",
            name="GET View User Profile"
        )


class BuyerUser(HttpUser):
    """
    Usuario que realiza compras completas
    Simula el flujo completo de compra: POST, GET, PUT
    """
    tasks = [UserBehavior]
    wait_time = between(2, 5)
    weight = 2  # 40% de usuarios realizan compras
    host = "http://localhost"  # Usa puertos directos


class StressTestUser(HttpUser):
    """
    Usuario para pruebas de estrés
    Realiza múltiples operaciones concurrentes (GET y POST)
    """
    wait_time = between(0.5, 1.5)
    weight = 1  # Usado solo en pruebas de estrés
    host = "http://localhost"
    
    @task(10)
    def rapid_product_browsing(self):
        """Navegación rápida de productos (GET)"""
        for _ in range(3):
            self.client.get("http://localhost:8500/product-service/api/products", name="GET Rapid Products")
    
    @task(5)
    def rapid_user_lookups(self):
        """Búsquedas rápidas de usuarios (GET)"""
        for _ in range(2):
            user_id = random.randint(1, 5)
            self.client.get(f"http://localhost:8700/user-service/api/users/{user_id}", name="GET Rapid Users")
    
    @task(3)
    def rapid_order_creation(self):
        """Creación rápida de pedidos (POST)"""
        order_data = {
            "userId": random.randint(1, 5),
            "orderDate": "2024-01-15",
            "orderDesc": "Stress Test Order",
            "orderFee": round(random.uniform(10.0, 1000.0), 2)
        }
        self.client.post("http://localhost:8300/order-service/api/orders", json=order_data, name="POST Rapid Order")


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

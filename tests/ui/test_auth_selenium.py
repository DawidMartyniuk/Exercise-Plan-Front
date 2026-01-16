from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import time
import os
import requests
from selenium.common.exceptions import TimeoutException
import pathlib

FRONT_URL = os.environ.get('FRONT_URL', "http://127.0.0.1:5173")
DEBUG_DIR = pathlib.Path("tests/ui/debug_screenshots")
DEBUG_DIR.mkdir(parents=True, exist_ok=True)

def wait_for_server(url: str, timeout: int = 20) -> bool:
    from time import time as _time, sleep
    start = _time()
    while _time() - start < timeout:
        try:
            r = requests.get(url, timeout=2)
            if 200 <= r.status_code < 600:
                return True
        except requests.RequestException:
            pass
        sleep(0.5)
    return False

def make_driver():
    options = webdriver.ChromeOptions()
    options.add_argument("--disable-web-security")
    options.add_argument("--user-data-dir=C:/chrome-dev-run")
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)
    driver.set_window_size(1200, 900)
    return driver

def _save_debug(driver, name: str):
    ts = int(time.time())
    png = DEBUG_DIR / f"{name}_{ts}.png"
    html = DEBUG_DIR / f"{name}_{ts}.html"
    try:
        driver.save_screenshot(str(png))
    except Exception:
        pass
    try:
        with open(html, "w", encoding="utf-8") as f:
            f.write(driver.page_source)
    except Exception:
        pass
    print(f"Saved debug: {png} {html}")

def test_register_ui():
    assert wait_for_server(FRONT_URL, timeout=30), f"Frontend not reachable at {FRONT_URL} — uruchom frontend przed testem"
    d = make_driver()
    try:
        d.get(FRONT_URL)
        # krótka pauza żeby animacje/modal się otworzyły
        time.sleep(1.0)
        wait = WebDriverWait(d, 20)
        try:
            open_btn = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, "[id=open_register], [data-test=open_register], button")))
            open_btn.click()
        except Exception:
            # zapisz debug jeśli przycisk nie działa
            _save_debug(d, "open_register_failed")
            # nie rethrow — kontynuujemy żeby spróbować znaleźć pola jeszcze raz
            pass

        try:
            inputs = wait.until(EC.presence_of_all_elements_located((By.CSS_SELECTOR, "input")))
        except TimeoutException:
            _save_debug(d, "no_inputs_found")
            raise

        # jeśli inputów za dużo/za mało -> dopasuj selektor ręcznie po obejrzeniu HTML
        inputs[0].send_keys("SeleniumUser")
        inputs[1].send_keys(f"selenium_{int(time.time())}@example.com")
        inputs[2].send_keys("Password1")
        if len(inputs) > 3:
            inputs[3].send_keys("Password1")

        submit = d.find_element(By.CSS_SELECTOR, "button[type=submit], [data-test=register_create_account], #register_create_account")
        submit.click()
        WebDriverWait(d, 12).until(EC.presence_of_element_located((By.CSS_SELECTOR, "input[name=email], [data-test=login_email]")))
    finally:
        d.quit()

def test_login_ui():
    assert wait_for_server(FRONT_URL, timeout=20), f"Frontend not reachable at {FRONT_URL} — uruchom frontend przed testem"
    d = make_driver()
    try:
        d.get(FRONT_URL)
        wait = WebDriverWait(d, 10)

        email_input = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "input[name=email], [data-test=login_email]")))
        email_input.send_keys("test@example.com")
        pwd_input = d.find_element(By.CSS_SELECTOR, "input[type=password], [data-test=login_password]")
        pwd_input.send_keys("Password1")
        login_btn = d.find_element(By.CSS_SELECTOR, "button[type=submit], [data-test=login_login_account]")
        login_btn.click()

        WebDriverWait(d, 8).until(EC.presence_of_element_located((By.CSS_SELECTOR, "[data-test=dashboard], .dashboard")))
    finally:
        d.quit()

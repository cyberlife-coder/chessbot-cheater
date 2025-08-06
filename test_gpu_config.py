from gpu_config import GPUConfig

def test_gpu_config():
    gpu = GPUConfig()
    print('GPU disponible:', gpu.cuda_available)
    print('Device info:', gpu.get_device_info())
    gpu.configure_tensorflow_gpu()
    gpu.configure_ultralytics_gpu()
    return gpu.cuda_available

if __name__ == "__main__":
    test_gpu_config()

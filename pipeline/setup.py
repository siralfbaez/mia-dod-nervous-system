import setuptools

REQUIRED_PACKAGES = [
    'apache-beam[gcp]==2.53.0',
    'google-cloud-aiplatform>=1.35.0',
    'google-cloud-storage>=2.10.0',
    'pg8000>=1.30.0',
]

setuptools.setup(
    name='mia_dod_pipeline',
    version='1.0.0',
    install_requires=REQUIRED_PACKAGES,
    packages=setuptools.find_packages(),
)

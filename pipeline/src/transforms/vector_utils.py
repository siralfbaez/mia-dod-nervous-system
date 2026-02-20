import apache_beam as beam
from vertexai.language_models import TextEmbeddingModel

class GetEmbeddings(beam.DoFn):
    def __init__(self, project, location):
        self.project = project
        self.location = location

    def setup(self):
        # Initializing the model once per worker
        self.model = TextEmbeddingModel.from_pretrained("text-embedding-004")

    def process(self, elements):
        # Vertex AI allows batching up to 250 instances
        inputs = [e['content'] for e in elements]
        embeddings = self.model.get_embeddings(inputs)

        for i, element in enumerate(elements):
            element['embedding'] = embeddings[i].values
            yield element
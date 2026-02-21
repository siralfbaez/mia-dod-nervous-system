import apache_beam as beam
from vertexai.language_models import TextEmbeddingModel
import logging

# Tags for branching the data stream
RAW_DATA_TAG = 'main_branch'
ERROR_TAG = 'dead_letter_queue'

class ProcessNeuralEmbedding(beam.DoFn):
    """
    Batches text for Vertex AI and handles embedding generation.
    """
    def __init__(self, project_id, region):
        self.project_id = project_id
        self.region = region

    def setup(self):
        # Initialize model on the worker node
        self.model = TextEmbeddingModel.from_pretrained("text-embedding-004")

    def process(self, element):
        try:
            # Business Logic: Ensure content exists
            content = element.get('content', '')
            if not content:
                raise ValueError("Empty content field")

            # In a real pipeline, you would batch these for efficiency
            embeddings = self.model.get_embeddings([content])
            element['embedding'] = embeddings[0].values
            
            # Send to the successful path
            yield element

        except Exception as e:
            # Send to the Dead Letter Queue (Side Output)
            logging.error(f"Failed to process record: {e}")
            yield beam.pvalue.TaggedOutput(ERROR_TAG, {
                'original_record': element,
                'error_message': str(e)
            })

class FormatForAlloyDB(beam.DoFn):
    """
    Prepares the dictionary for a SQL INSERT into the neural_records table.
    """
    def process(self, element):
        # Flattening or mapping to match your 01_init_vector.sql schema
        yield {
            'content': element['content'],
            'embedding': element['embedding'],
            'metadata': element.get('metadata', {})
        }

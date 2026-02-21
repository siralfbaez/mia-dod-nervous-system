import pytest
import apache_beam as beam
from apache_beam.testing.test_pipeline import TestPipeline
from apache_beam.testing.util import assert_that, equal_to
from pipeline.src.transforms.neural_processors import ProcessNeuralEmbedding, ERROR_TAG

def test_process_neural_embedding_error_handling():
    # Test data with a missing 'content' field to trigger the DLQ
    data = [
        {'id': '1', 'content': 'Valid message'},
        {'id': '2'} # Malformed: Missing content
    ]

    with TestPipeline() as p:
        input_pcoll = p | beam.Create(data)

        # We wrap the transform and capture the side outputs
        results = input_pcoll | beam.ParDo(
            ProcessNeuralEmbedding(project_id="test-proj", region="us-east1")
        ).with_outputs(ERROR_TAG, main='main')

        # Verify that the malformed record ended up in the Dead Letter Queue
        assert_that(
            results[ERROR_TAG],
            equal_to([{'original_record': {'id': '2'}, 'error_message': "Empty content field"}]),
            label='CheckDLQ'
        )
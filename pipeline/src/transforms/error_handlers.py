import apache_beam as beam

class HandleErrors(beam.PTransform):
    def __init__(self, dead_letter_tag):
        self.dead_letter_tag = dead_letter_tag

    def expand(self, pcoll):
        return pcoll | beam.ParDo(self._process).with_outputs(self.dead_letter_tag, main='main')

    def _process(self, element):
        try:
            # Add your strict validation logic here
            if not element.get('content'):
                raise ValueError("Missing 'content' field")
            yield element
        except Exception as e:
            yield beam.pvalue.TaggedOutput(self.dead_letter_tag, {'payload': element, 'error': str(e)})
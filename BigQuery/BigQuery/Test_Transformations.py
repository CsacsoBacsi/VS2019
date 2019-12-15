import apache_beam as beam
import apache_beam.options.pipeline_options as opt
import apache_beam.transforms.window as window

class convDict (beam.DoFn):
    def process (self, element):
        columns = ['id1', 'id2', 'val1']
        values =  element.split (b',')
        values [0] = int (values [0])
        values [1] = int (values [1])
        d = dict (zip (columns, values))
        print (d)
        return [d]

class sumList (beam.DoFn):
    def process (self, element):
        element = element    
        retval = [{'item':element[0], 'sum_total':sum (element[1])}]
        return [retval]

class watchIt (beam.DoFn):
    def process (self, element):
        element = element
        return [element]

class SumList (beam.CombineFn):
  def create_accumulator(self):
    return (0)

  def add_input (self, sum_count, input):
    (sum) = sum_count
    return sum + input

  def merge_accumulators (self, accumulators):
    sums = zip(*accumulators)
    return sum (sums)

  def extract_output(self, sum_count):
    (sum) = sum_count
    return {'Sum': sum}
  def default_label(self):
    return self.__class__.__name__

pipeline_options = opt.PipelineOptions ()
pipeline_options.view_as (opt.StandardOptions).streaming = False
#options=pipeline_options

with beam.Pipeline () as p: # Creates a pipeline
       
    lines = (p | "Create from in-memory List" >> beam.Create ([ # Create
                 'To be, or not to be: that is the question: ',
                 'Whether \'tis nobler in the mind to suffer ',
                 'The slings and arrows of outrageous fortune, ',
                 'Or to take arms against a sea of troubles, ']))
    
    # Example 1
    msg = ["5, 5, Five Five"]

    words = p | beam.Create (["Cat", "Mouse", "Horse", "Chimpanzee", "Fish"])
    
    #words = ["Cat" "Mouse", "Horse", "Chimpanzee", "Fish"]

    # PCollection: immutable, elements are of same type, no random access. Can be bounded or stream. Windows are used with timestamps

    # Transforms: ParDo, Combine, composite: combines core transforms
    ''' [Final Output PCollection] = ([Initial Input PCollection] | [First Transform]
        | [Second Transform]
        | [Third Transform]) '''

    # Apply a ParDo to the PCollection "words" to compute lengths for each word.
    # ParDo: “Map” phase of a Map/Shuffle/Reduce-style algorithm
    # Filter, convert, pick part of the data, simple computation
    # You must supply a DoFn class
    
    rows = msg | "Convert to dict" >> beam.ParDo (convDict ()) 

    word_lengths = words | beam.Map (lambda word: {"col1":word, "val1":len (word)})

    word_lengths | beam.io.WriteToBigQuery (table='testtable',
                                            dataset="mydataset",
                                            project="famous-store-237108",
                                            schema='col1:STRING, val1:INTEGER',
                                            create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
                                            write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND)

    # Example 2
    dataset_dict = [{"item1":2}, {"item2":5}, {"item3": 1}, {"item1":3}, {"item1:":2}, {"item3":5}]
    dataset = [("item1",2), ("item2",5), ("item3", 1), ("item1",3), ("item1",7), ("item3",5)]

    pairs = (p | "Create from in-memory Dictionary" >> beam.Create (dataset))

    grouped = pairs | beam.GroupByKey ()
    summed = grouped | beam.ParDo (sumList ())
    #result = grouped | beam.CombineGlobally (SumList ())

    watchit = summed | beam.ParDo (watchIt ())

    p = "more"
    o = p + "bg"

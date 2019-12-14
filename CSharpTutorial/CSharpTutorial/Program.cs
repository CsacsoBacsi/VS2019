using System ;
using System.Collections.Generic ;
using System.Linq ;
using System.Text ;
using System.Threading.Tasks ;
using System.Threading ;
using System.IO ;

namespace CSharpTutorial
{
    class Program 
    {
        private static readonly Object lock_obj = new Object (); // Threads put a lock on these objects
        private static int critical_obj = 0 ;  // The object to be protected by a lock in a thread
        enum Days { Sun, Mon, tue, Wed, thu, Fri, Sat } ;
        delegate void Arithmetic (int val) ; // Function pointer to functions returning nothing and expecting an int parameter

        static unsafe void Main (string[] args)
        {
            Program p = new Program () ;
            const double pi = 3.14159 ;

            Console.WriteLine ("Hello World") ;
            Console.WriteLine ("Size of decimal: {0}", sizeof (decimal)) ;

            // Reference types: object, dynamic, String
            object obj ; // The base class of all types
            obj = 100 * pi ; // This is boxing
            Console.WriteLine ("Unboxing int: {0}", (double) obj) ;
            dynamic dyn = 30 ; // Type check at runtime not at compile time
            dyn = "String" ;
            String str = "Hi there!" ;
            Console.WriteLine (str) ;
            // Pointers are the same as in C++
            // char * cptr ;

            // Type conversion
            double d = 5673.74 ;
            int i ;
            i = (int) d ; // Implicit cast double to int
            Console.WriteLine (d.ToString ()) ; // Explicit conversion
            int i32 = Convert.ToInt32 (i) ;

            // User input
            int num;
            num = Convert.ToInt32 (Console.ReadLine ()) ;

            // Pass by reference
            int k = 2 ;
            Console.WriteLine ("Before: " + k) ;
            p.Twice (ref k) ;
            Console.WriteLine ("After: " + k) ; // k is changed by the private method

            // Out parameters
            int o;
            o = p.GetValues (out int m, out int n, out int r) ; // Do not have to be initialized. Plus, it can return a value
            Console.WriteLine ("m and n and r and m * n * r: " + m + ", " + n + ", " + r + ", " + o) ;

            // Nullables
            double? num1 = null; // Question mark denotes nullable
            double? num2 = 3.14157;
            double? num3;
            num3 = num1 ?? num2 ; // NVL operator. Take first operand if not null otherwise second

            // Arrays
            int [] n_arr = new int [10] ; // Reference type so we need the new operator
            int [] marks = new int [] { 99, 98, 92, 97, 95 }; // Declare without subscript
            int [] score = marks ; // Copy one array into another
            double [] balance = new double [10] ;
            int l = 0 ;
            foreach (int j in n_arr) // Foreach statement
            {
                Console.WriteLine ("Element[{0}] = {1}", l, j) ;
                l ++ ;
            }

            int [,] a = {{0, 1, 2, 3}, {4, 5, 6, 7}, {8, 9, 10, 11}} ;

            int [][] scores = new int [2][] { new int [] {92, 93, 94}, new int [] {85, 66, 87, 88}} ; // Jagged arrays. Array of variable length arrays

            int [] list = {34, 72, 13, 44, 25, 30, 10} ; // Array class usage
            int [] temp = list ;
            Array.Reverse (temp) ;
            Array.Sort (list) ;

            // Strings
            char [] letters = {'H', 'e', 'l', 'l', 'o'} ;
            string greetings = new string (letters) ;
            string [] sarray = {"Hello", "From", "Tutorials", "Point"} ;

            DateTime waiting = new DateTime (2012, 10, 10, 17, 58, 1) ;
            string chat = String.Format ("Message sent at {0:t} on {0:D}", waiting) ;
            String.Compare(sarray[1], sarray[2]) ;
            if (sarray[1].Contains ("ll"))
            {
                Console.WriteLine ("Contains it!") ;
            }
            Console.WriteLine ("Substring: " + sarray[1].Substring (3)) ;

            // Properties
            Student s = new Student (5)
            {

                Code = "001",
                Name = "Zsurni",
                Age = 29
            } ;
            
            s.Age ++ ;
            Console.WriteLine ("Zsurni's age: " + s.Age) ;
            Console.WriteLine ("Zsurni's age: " + s.Score) ;

            // Unsafe code - Pointers
            int var = 20 ;
            int * pvar = &var ;
            Console.WriteLine ("Data is: {0} ", pvar->ToString ()) ; // -< is property of a pointer or method of a pointer

            int[] numlist = {10, 100, 200} ;
            fixed (int * ptr = numlist) { // Array addresses are fixed. Immutables
                Console.WriteLine ("Address of number list[{0}]={1}", 1, (int)(ptr + 1)) ;
            }

            // Threads
            Console.WriteLine ("In Main: Creating the Child thread");
            ThreadStart childref = new ThreadStart (CallToChildThread) ;
            Thread childThread = new Thread (childref) ;
            childThread.Start () ;
            Thread.Sleep (2000) ; // Suspend it for 2 secs 
            Console.WriteLine ("In Main: Aborting the Child thread") ;
            childThread.Abort () ; // Stop the thread
            Thread.Sleep (1000) ; // Wait until child stops

            // Enums
            int WeekdayStart = (int) Days.Mon ;
            int WeekdayEnd = (int) Days.Fri ;
            Console.WriteLine ("Monday: {0}", WeekdayStart) ;
            Console.WriteLine ("Friday: {0}", WeekdayEnd) ;
            
            // Classes - inheritance
            Uni myuni = new Uni (4, "Magyar") ;
            Console.WriteLine ("Uni student's age: " + myuni.Age) ;
            Console.WriteLine ("Uni student score: " + myuni.Score) ;
            Console.WriteLine ("Uni student has diploma? " + myuni.GetDiploma ().ToString ()) ;
            Console.WriteLine ("Uni student language: " + myuni.lang) ;
            // Console.WriteLine ("Student language " + ((Uni)s).lang) ; // Exception: failed to cast s to Uni

            // Polymorphism
            Base  _base  = new Base  () ;
            BaseA _baseA = new BaseA () ;
            BaseB _baseB = new BaseB () ;

            BaseX _baseX = new BaseX () ;
            // Console.WriteLine ("Calling Base..." + _base.callGetResult ((Base)_base)) ; // No such method
            Console.WriteLine ("Calling BaseA..." + _baseX.CallGetResult ((Base)_baseA)) ;
            Console.WriteLine ("Calling BaseB..." + _baseX.CallGetResult ((Base)_baseB)) ;

            // Operator overloading
            Base base1 = new Base () ;
            Base base2 = new Base () ;
            base1.v = 2 ;
            base2.v = 4 ;
            base1.w = 7 ;
            base2.w = 9 ;
            Base br = base1 / base2 ;
            Console.WriteLine ("Operator overload result: " + (int)(br.v + br.w)) ;

            // Interfaces
            Shape myShape = new Shape () ;
            myShape.SetLW (3, 4) ;
            myShape.Enlarge (2) ;
            Console.WriteLine ("Shape area: " + myShape.GetArea ()) ; // Call interface method

            // Exceptions - try - catch
            Divider dvd = new Divider () ;

            try {
                Console.WriteLine ("100 divided by 50 is: " + dvd.divide100 (50)) ;
                Console.WriteLine ("Trying to divide by zero...") ;
                Console.WriteLine ("100 divided by 0 is: " + dvd.divide100 (0)) ;
            }
            catch (DividerException de)
            {
                Console.WriteLine ("Exception caught: " + de.Message) ;
            }
            finally
            {
                Console.WriteLine ("No more dividing!") ;
            }

            // File I/O
            FileStream fhandle = new FileStream ("testfile.dat", FileMode.OpenOrCreate, FileAccess.ReadWrite) ;
            for (int i1 = 1 ; i1 <= 10 ; i1 ++)
            {
                fhandle.WriteByte ((byte) i1) ; // Binary write. Writes binary 0,1,2,3,4,5,6,7,8,9,0A
            }
            fhandle.Position = 0 ; // Set file pointer to beginning

            for (int i1 = 0 ; i1 <= 10 ; i1 ++)
            {
                Console.Write (fhandle.ReadByte () + " ") ; // Converts it to ASCII
            }
            fhandle.Close () ;

            // Text file use
            using (StreamReader sr = new StreamReader ("./textfile.txt")) // The class must implement IDisposable
            {
                string record ;

                while ((record = sr.ReadLine ()) != null) // Read line by line until EOF
                {
                    Console.WriteLine (record) ;
                }
            } // Using calls dispose () when the block is left which means it gets rid of (closes) the StreamReader
              // Same as try {Operate on stream reader}finally {if stream reader is not null then Dispose ()}

            // Binary files
            BinaryWriter bw = null ; // Must be initialized otherwise compilation error
            BinaryReader br2 = null ;

            int i3 = 128 ;
            double d3 = 456.321 ;
            Boolean b3 = true ;
            string s3 = "My string" ;

            try
            {
                bw = new BinaryWriter (new FileStream ("binfile.bin", FileMode.OpenOrCreate)) ;
            }
            catch (IOException e)
            {
                Console.WriteLine (e.Message + "\n Cannot create file.") ;
            }

            try
            {
                bw.Write (i3) ;
                bw.Write (d3) ;
                bw.Write (b3) ;
                bw.Write (s3) ;
            }
            catch (IOException e)
            {
                Console.WriteLine (e.Message + "\n Cannot write to file.");
            }
            bw.Flush () ; // Flush the buffers (write data in memory to disk)
            bw.Seek (-3, SeekOrigin.End) ;
            bw.Write ('x') ;
            bw.Flush () ;
            bw.Close () ;

            try
            {
                br2 = new BinaryReader (new FileStream ("binfile.bin", FileMode.Open)) ;
            }
            catch (IOException e)
            {
                Console.WriteLine (e.Message + "\n Cannot open file.");
            }
            try
            {
                i3 = br2.ReadInt32 ();
                Console.WriteLine ("Integer data: {0}", i3) ;
                d3 = br2.ReadDouble ();
                Console.WriteLine ("Double data: {0}", d3) ;
                b3 = br2.ReadBoolean ();
                Console.WriteLine ("Boolean data: {0}", b3) ;
                s3 = br2.ReadString ();
                Console.WriteLine ("String data: {0}", s3) ;
            }
            catch (IOException e)
            {
                Console.WriteLine (e.Message + "\n Cannot read from file.");
            }
            br2.BaseStream.Seek (-3, SeekOrigin.End) ; // Seek while reading via BaseStream
            Console.WriteLine ("Char at end - 3: " + br2.ReadChar ()) ;
            br2.Close () ;

            // Directory and file info
            //creating a DirectoryInfo object
            DirectoryInfo mydir = new DirectoryInfo ("D:/Pictures") ;

            // Getting the files in the directory, their names and size
            FileInfo[] f = mydir.GetFiles () ;
            foreach (FileInfo file in f)
            {
                Console.WriteLine ("File Name: {0} Size: {1}", file.Name, file.Length) ;
            }
            // Getting the sub-directories in the directory, their names and parents
            DirectoryInfo[] d2 = mydir.GetDirectories ();
            foreach (DirectoryInfo dir in d2)
            {
                Console.WriteLine ("Dir Name: {0} Parent: {1}", dir.Name, dir.Parent) ;
            }

            // Indexers
            Teacher tch = new Teacher () ; // If the class has an array as a member and we want to access these members via the instance with an index
            tch[0] = "Student 1" ;
            tch[5] = "Student 5" ;
            tch[29] = "Student 30" ;
            tch[30] = "Invalid" ; // The set method will discard it

            for (int i5 = 0 ; i5 < 30 ; i5 ++)
            {
                Console.WriteLine ("Student number {0} is {1}", i5, tch[i5]) ;
            }

            // Delegates
            DelegateTest dlg = new DelegateTest () ; // The instance that holds 3 arithmetic methods
            Arithmetic aradd = new Arithmetic (dlg.AddMyNum) ; // Delegates = Function pointers
            Arithmetic armul = new Arithmetic (dlg.MulMyNum) ;
            Arithmetic ardiv = new Arithmetic (dlg.DivMyNum) ;

            aradd (50) ; // Call the functions these function pointers point at
            armul (2) ;
            ardiv (30) ;
            Console.WriteLine ("My number: {0}", dlg.GetMyNum ()) ; // (100 + 50) * 2 / 30 = 10

            aradd += armul ; // Multicast
            aradd (10) ; // Bothfunctions get called with the same parameter. Functions of the same signature can be multicast only
            Console.WriteLine ("My number after multicast: {0}", dlg.GetMyNum ()) ; // (10 + 10) * 10 = 200

            // Events
            EventProducer ep = new EventProducer () ;
            EventListener el = new EventListener () ;
            el.Listen (ep) ; // Set the listener to listen on the producer event
            ep.Start () ; // Start the the loop

            // Wait for a keystroke
            Console.ReadKey () ;

        }

        private void Twice (ref int i) // Pass by reference
        {
            i *= 2 ;
        }

        private int GetValues (out int x, out int y, out int z) // Out parameters
        {
            x = 5 ;
            y = 6 ;
            z = 10 ;
            return x * y * z ;
        }

        public static void CallToChildThread ()
        {
            try
            {
                Console.WriteLine ("Child thread starts") ;
                for (int counter = 0 ; counter <= 10 ; counter ++)
                {
                    Thread.Sleep (500) ;
                    Console.WriteLine ("Tick #{0}", counter) ;
                    lock (lock_obj)
                    {
                        critical_obj ++ ;
                    }
                    // Same as: System.Threading.Monitor.Enter (temp) ; // Same as lock
                    //try
                    //{
                    //}
                    //finally
                    //{
                    //    System.Threading.Monitor.Exit (temp);
                    //}
                }
                Console.WriteLine ("Child Thread ticked down");
            }
            catch (ThreadAbortException e)
            {
                Console.WriteLine ("Thread Abort Exception handled.{0}", e.ToString ()) ;
            }
            finally
            {
                Console.WriteLine ("Couldn't catch the Thread Exception");
            }
        }
    }

    // Properties
    class Student
    {
        private string code = "N/A" ;
        private string name = "Unknown" ;
        private int age = 0 ;
        private int score ;
        protected Boolean hasDiploma ;

        public Student ()
        {
            this.hasDiploma = false ;
            Console.WriteLine ("Object is being created (default)") ;
        }
        public Student (int _score)  // Constructor
        {
            this.score = _score ;
            this.hasDiploma = false ;
            Console.WriteLine ("Object is being created (score)") ;
        }
        ~Student () // Destructor
        {
            Console.WriteLine ("Object is being destroyed") ;
        }


        public string Code
        {
            get { return code ; } // Private member (field) accessed via property
            set { code = value ; }
        }
        public string Name
        {
            get {return name ; }
            set {name = value ; }
        }
        public int Age
        {
            get {return age ; }
            set {age = value ; }
        }
        public int Score
        {
            get {return score ; }
            set {age = value ; }
        }
    }

    // Inheritance
    class Uni: Student
    {
        public string lang = "English" ;

        public Uni ()
        {
            Console.WriteLine ("Default constructor for Uni") ;
        }

        public Uni (int _score, string _lang) : base (_score) // First the base class is created
        {
            lang = _lang ;
            Console.WriteLine ("Object is being created (Uni)") ;
        }

        public Boolean GetDiploma ()
        {
            Age = 49 ; // Public property
            // age = 15 ; // Private so can not be accessed
            return hasDiploma ; // Protected member so the derived class can access it
        }
    }

    // Polymorphism
    class Base // Base class
    {
        protected int x = 5, y = 6 ;
        public int v, w ;

        public virtual int GetResult () // Must be declared virtual for polymorphism
        {
            Console.WriteLine ("Base class getResult") ;
            return 0 ;
        }

        public static Base operator / (Base b1, Base b2) // Operator overloading
        {
            Base br = new Base () ;
            br.v = b1.v + b2.v ;
            br.w = b1.w + b2.w ;
            return br ;
        }
    }
    class BaseA : Base // Derived class
    {
        public override int GetResult () // Must override the virtual method
        {
            Console.WriteLine ("BaseA class getResult");
            return x * y ;
        }
    }
    class BaseB : Base // Derived class
    {
        public override int GetResult ()
        {
            Console.WriteLine ("BaseB class getResult");
            return x + y ;
        }
    }
    class BaseX
    {
        public int CallGetResult (Base thisBase) // thisBase is of Base type so both BaseA and BaseB is accepted as parameter
        {
            return thisBase.GetResult () ; // At run-time the correct getResult function will be called with the correct arithmetic
        }
    }

    // Interfaces
    public interface IArea
    {
        int GetArea () ;
        int GetCircumreference () ;
        void Enlarge (int e) ;
    }

    class Shape : IArea // Implements that interface
    {
        private int length ;
        private int width ;

        public int GetArea () // Interface methods. Must all 3 be implemented!
        {
            return length * width ;
        }
        public int GetCircumreference ()
        {
            return 2 * length + 2 * width ;
        }
        public void Enlarge (int enlrg)
        {
            length *= enlrg ;
            width  *= enlrg ;
        }
        public void Quadrat () // Own methods. Not part of the interface
        {
            length = width ;
        }
        public void SetLW (int x, int y)
        {
            length = x ;
            width = y ;
        }
    }

    class Divider
    {
        private int dividee = 100 ;

        public float divide100 (int diviser)
        {
            if (diviser == 0)
            {
                throw (new DividerException ("Trying to divide by zero!")) ;
            }
            return dividee / diviser ;
        }
    }

    class DividerException: Exception
    {
        public DividerException (string errmsg): base (errmsg)
        {

        }
    }

    // Indexer class
    class Teacher
    {
        protected string [] students = new string [30] ; // 30 students. Get and set will access it same way as properties

        public Teacher () // Initialize the string array
        {
            for (int i = 0 ; i < 30 ; i ++)
            {
                students [i] = "N/A" ;
            }
        }

        public string this [int index] // Same as a property but here we use "this" which means the instance created from the class
        {
            get
            {
                if (index >= 0 && index < 30) // Must check the subscript to avoid exceptions getting raised
                {
                    return students [index] ;
                }
                else
                {
                    return "N/A" ;
                }
            }
            set
            {
                if (index >= 0 && index < 30)
                {
                    students [index] = value ;
                }
            }
        }
    }

    // Delegates
    class DelegateTest
    {
        private double mynum = 100 ;

        public void AddMyNum (int addendum)
        {
            mynum += addendum ;
        }
        public void MulMyNum (int multiplier)
        {
            mynum *= multiplier ;
        }
        public void DivMyNum (int divider)
        {
            mynum /= divider ;
        }
        public double GetMyNum ()
        {
            return mynum ;
        }
    }

    // Events
    public class EventParams : EventArgs // Needs an object of EventArgs type
    {
        private int eventparam1; // Variable behind property
        public int ep1 // Property
        {
            set
            {
                eventparam1 = value;
            }
            get
            {
                return this.eventparam1;
            }
        }
    }

    public class EventProducer
    {
        public delegate void EventHandler (EventProducer ep, EventParams e) ; // Delegate function pointer. Signature: EventProducer, EventParams
        public event EventHandler MyEvent ; // Event handler which is of delegate type. We need to add the handler function(s) to it
        public EventParams e = new EventParams () ; // Instantiate event parameters. Must derive from EventArgs

        public void Start () // Some sort of loop in which event occur
        {
            e.ep1 = 0 ;
            while (true)
            {
                Thread.Sleep (1000) ; // Sleep 1 sec
                
                e.ep1 ++ ;
                System.Console.WriteLine ("Parameter: " + e.ep1);
                if (e.ep1 == 5) // Fire event if reaches 5 secs
                {
                    if (MyEvent != null) // Must have a handler specified
                    {
                        MyEvent (this, e) ; // Fires the event. this = instance of EventProducer, e = event parameters type with ep1 as property
                    }
                }
                if (e.ep1 == 7)
                {
                    break ; // Terminate the loop
                }
            }
        }
    }

    public class EventListener
    {
        public void Listen (EventProducer ep) // Hooks up the event handler function with the event of delegate type
        {
            ep.MyEvent += new EventProducer.EventHandler (EventFunc) ; // Special syntax to add an event handler function
        }
        private void EventFunc (EventProducer ep, EventParams e) // The actual function that will handle the event
        {
            System.Console.WriteLine ("Event received and handled. Parameter: " + e.ep1) ;
        }
    }
}

// Write line
/* Console.WriteLine("Standard Numeric Format Specifiers");
    Console.WriteLine(
        "(C) Currency: . . . . . . . . {0:C}\n" +
        "(D) Decimal:. . . . . . . . . {0:D}\n" +
        "(E) Scientific: . . . . . . . {1:E}\n" +
        "(F) Fixed point:. . . . . . . {1:F}\n" +
        "(G) General:. . . . . . . . . {0:G}\n" +
        "    (default):. . . . . . . . {0} (default = 'G')\n" +
        "(N) Number: . . . . . . . . . {0:N}\n" +
        "(P) Percent:. . . . . . . . . {1:P}\n" +
        "(R) Round-trip: . . . . . . . {1:R}\n" +
        "(X) Hexadecimal:. . . . . . . {0:X}\n",
        -123, -123.45f); 

    Console.WriteLine("Standard DateTime Format Specifiers");
    Console.WriteLine(
        "(d) Short date: . . . . . . . {0:d}\n" +
        "(D) Long date:. . . . . . . . {0:D}\n" +
        "(t) Short time: . . . . . . . {0:t}\n" +
        "(T) Long time:. . . . . . . . {0:T}\n" +
        "(f) Full date/short time: . . {0:f}\n" +
        "(F) Full date/long time:. . . {0:F}\n" +
        "(g) General date/short time:. {0:g}\n" +
        "(G) General date/long time: . {0:G}\n" +
        "    (default):. . . . . . . . {0} (default = 'G')\n" +
        "(M) Month:. . . . . . . . . . {0:M}\n" +
        "(R) RFC1123:. . . . . . . . . {0:R}\n" +
        "(s) Sortable: . . . . . . . . {0:s}\n" +
        "(u) Universal sortable: . . . {0:u} (invariant)\n" +
        "(U) Universal full date/time: {0:U}\n" +
        "(Y) Year: . . . . . . . . . . {0:Y}\n", 
        thisDate);

    Console.WriteLine("Standard Enumeration Format Specifiers");
    Console.WriteLine(
        "(G) General:. . . . . . . . . {0:G}\n" +
        "    (default):. . . . . . . . {0} (default = 'G')\n" +
        "(F) Flags:. . . . . . . . . . {0:F} (flags or integer)\n" +
        "(D) Decimal number: . . . . . {0:D}\n" +
        "(X) Hexadecimal:. . . . . . . {0:X}\n", 
        Color.Green);       
*/

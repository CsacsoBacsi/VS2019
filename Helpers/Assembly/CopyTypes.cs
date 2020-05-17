using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading;

struct Height
{
    private int m_inches;

    public int Inches
    {
        get { return m_inches; }
        set { m_inches = value; }
    }
}

class Employee
{
    private string m_name;
    public string member1;
    public string member2;

    public string Name
    {
        get { return m_name; }
        set { m_name = value; }
    }

    public Employee (string member1, string member2)
    {
        this.member1 = member1;
        this.member2 = member2;
    }

    public Employee ()
    {
    }
}

public class CopyTypes
{
    public CopyTypes()
    {
    }

    public static void Main1()
    {
        Height joe = new Height();
        joe.Inches = 71;

        Height bob = new Height();
        bob.Inches = 59;

        Console.WriteLine("Original Height Values:");
        Console.WriteLine("joe = " + joe.Inches);
        Console.WriteLine("bob = " + bob.Inches);

        // assign joe value to bob variable
        bob = joe;

        Console.WriteLine();
        Console.WriteLine("Values After Value Assignment:");
        Console.WriteLine("joe = " + joe.Inches);
        Console.WriteLine("bob = " + bob.Inches);

        joe.Inches = 65;

        Console.WriteLine();
        Console.WriteLine("Values After Changing One Instance:");
        Console.WriteLine("joe = " + joe.Inches);
        Console.WriteLine("bob = " + bob.Inches);

        Employee joe2 = new Employee();
        joe2.Name = "Joe2";

        Employee bob2 = new Employee();
        bob2.Name = "Bob2";

        Console.WriteLine("Original Employee Values:");
        Console.WriteLine("joe2 = " + joe2.Name);
        Console.WriteLine("bob2 = " + bob2.Name);

        // assign joe reference to bob variable
        bob2 = joe2;

        Console.WriteLine();
        Console.WriteLine("Values After Reference Assignment:");
        Console.WriteLine("joe2 = " + joe2.Name);
        Console.WriteLine("bob2 = " + bob2.Name);

        joe2.Name = "Bobbi Jo";

        Console.WriteLine();
        Console.WriteLine("Values After Changing One Instance:");
        Console.WriteLine("joe2 = " + joe2.Name);
        Console.WriteLine("bob2 = " + bob2.Name);

        bob2.Name = "Jo Bobbi";

        Console.WriteLine();
        Console.WriteLine("Values After Changing the other Instance:");
        Console.WriteLine("joe2 = " + joe2.Name);
        Console.WriteLine("bob2 = " + bob2.Name);
    }
}

public class LinqExamples 
{
    public static void Main2()
    {
        // Linq examples
        // Anonymous object
        string[] words = {"aPPLE", "BlUeBeRrY", "cHeRry"};

        var upperLowerWords =
            from w in words
            // w is an individual string
            select new {Upper = w.ToUpper(), Lower = w.ToLower(), iLength = w.Length};

        foreach (var ul in upperLowerWords)
        {
            Console.WriteLine("Uppercase: {0}, Lowercase: {1}, Length: {2}", ul.Upper, ul.Lower, ul.iLength);
        }

        // Selecting members and creating a new anonymous object as well
        List<Employee> NameList = new List<Employee>();
        NameList.Add(new Employee("Csacsi", "Bacsi"));
        NameList.Add(new Employee("Vila", "Tunder"));
        NameList.Add(new Employee("Employee", "Adam"));
        NameList.Add(new Employee("Employee", "Mike"));
        NameList.Add(new Employee("Employee", "Frida"));

        var fullname = from names in NameList
                       select new {names.member1, names.member2, FullName = names.member1 + " " + names.member2};
        foreach (var n in fullname)
        {
            Console.WriteLine("Fullnames: {0}", n.FullName);
        }

        // Lambda expression
        int[] numbers = {5, 4, 1, 3, 9, 8, 6, 7, 2, 0};

        var numsInPlace = numbers.Select((num, index) => new {Num = num, InPlace = (num == index)});
        // num and index are both the actual integer values

        Console.WriteLine("Number: In-place?");
        foreach (var n in numsInPlace)
        {
            Console.WriteLine("{0}: {1}", n.Num, n.InPlace);
        }

        // Filtering
        int[] numbers2 = {5, 4, 1, 3, 9, 8, 6, 7, 2, 0};

        var numsInPlace2 =
            numbers2.Where(num => (num < 8)).Select((num, index) => new {Num = num, InPlace = (num == index)});
        // The second param to Select is the actual index of the item in the array

        Console.WriteLine("Number: In-place?");
        foreach (var n in numsInPlace2)
        {
            Console.WriteLine("{0}: {1}", n.Num, n.InPlace);
        }

        // Multiple tables
        int[] numbersA = {0, 2, 4, 5, 6, 8, 9};
        int[] numbersB = {1, 3, 5, 7, 8};

        var pairs =
            from a in numbersA
            from b in numbersB
            where a < b
            select new {a, b};

        Console.WriteLine("Pairs where a < b:");
        foreach (var pair in pairs)
        {
            Console.WriteLine("{0} is less than {1}", pair.a, pair.b);
        }

        // Use the index of an item
        string[] someItems = {"cat", "dog", "purple elephant", "unicorn"};
        var selectedItems = someItems.Select((item, indexem) => new {ItemName = item, Position = indexem});

        foreach (var item in selectedItems)
        {
            Console.WriteLine("Item: {0}, Position: {1}", item.ItemName, item.Position);
        }

        // Order by
        string[] words2 = {"aPPLE", "AbAcUs", "bRaNcH", "BlUeBeRrY", "ClOvEr", "cHeRry"};

        var sortedWords = words2.OrderBy(a => a, new CaseInsensitiveComparer());
        foreach (var item in sortedWords)
        {
            Console.WriteLine("Item: {0}", item);
        }

        var fulln = from names in NameList
                    orderby names.member1 + " " + names.member2
                    select new { names.member1, names.member2, FullName = names.member1 + " " + names.member2 };

        var fulln2 = NameList.OrderByDescending(a => a.member1 + " " + a.member2).Select(a => new { FullName = a.member1 + " " + a.member2 });

        // Two orderbys reorder the list twice
        var fulln3 = NameList.OrderBy (n => n.member1 + " " + n.member2)
                             .OrderBy (n => n.member2)
                             .Select (n => new { n.member1, n.member2, FullName = n.member1 + " " + n.member2 });

        // ThenBy creates a composite ordering
        var fulln4 = NameList.OrderBy(n => n.member1 + " " + n.member2)
                             .ThenBy(n => n.member2)
                             .Select(n => new { n.member1, n.member2, FullName = n.member1 + " " + n.member2 });


        foreach (var n in fulln4)
        {
            Console.WriteLine("Fullnames: {0}", n.FullName);
        }

        // Distinct, union, intersect, except

        int[] factorsOf300 = { 2, 2, 3, 5, 5 };       
        var uniqueFactors = factorsOf300.Distinct();

        Console.WriteLine("Prime factors of 300:");
        foreach (var f in uniqueFactors)
        {
            Console.WriteLine(f);
        }

        int[] numberA = { 0, 2, 4, 5, 6, 8, 9 };
        int[] numberB = { 1, 3, 5, 7, 8 };

        var uniqueNumbers = numberA.Union(numberB).OrderBy(a => a);

        Console.WriteLine("Unique numbers from both arrays:");
        foreach (var n in uniqueNumbers)
        {
            Console.WriteLine(n);
        }

        var commonNumbers = numbersA.Intersect(numbersB);
        Console.WriteLine("Common numbers from both arrays:");
        foreach (var n in commonNumbers)
        {
            Console.WriteLine(n);
        }

        var aOnlyNumbers = numbersA.Except(numbersB);

        Console.WriteLine("Numbers in first array but not second array:");
        foreach (var n in aOnlyNumbers)
        {
            Console.WriteLine(n);
        } 

        // Cross join    
        Table1[] tbl1 = new Table1[3];
        Table2[] tbl2 = new Table2[4];

        tbl1[0] = new Table1(1, 1, "Name1");
        tbl1[1] = new Table1(2, 2, "Name2");
        tbl1[2] = new Table1(3, 3, "Name3");

        tbl2[0] = new Table2(1, "Bramble Road");
        tbl2[1] = new Table2(2, "Howthorne Road");
        tbl2[2] = new Table2(3, "Bristol Road");
        tbl2[3] = new Table2(4, "Nowhere Road");

        var q = from t1 in tbl1
               join t2 in tbl2 on t1.premise_id equals t2.premise_id
               select new { Entity_id = t1.entity_id, Premise_id = t1.premise_id, Name = t1.name, Address = t2.address };

        Console.WriteLine("Cross join");
        foreach (var v in q)
        {
            Console.WriteLine (v.Entity_id + ": " + v.Address);
        } 

        // Group join
        var customers = new List<Customer>() { 
        new Customer {Keyid = 1, Name = "Gottshall" },
        new Customer {Keyid = 2, Name = "Valdes" },
        new Customer {Keyid = 3, Name = "Gauwain" },
        new Customer {Keyid = 4, Name = "Deane" },
        new Customer {Keyid = 5, Name = "Zeeman" }};

        var orders = new List<Order>() {
        new Order {Keyid = 1, OrderNumber = "Order 1", Amount = 5 },
        new Order {Keyid = 1, OrderNumber = "Order 2", Amount = 8 },
        new Order {Keyid = 4, OrderNumber = "Order 3", Amount = 2 },
        new Order {Keyid = 4, OrderNumber = "Order 4", Amount = 11 },
        new Order {Keyid = 5, OrderNumber = "Order 5", Amount = 9 },
        new Order {Keyid = 6, OrderNumber = "Order 6", Amount = 7 }};

        var q0 = from c in customers
                 join o in orders on c.Keyid equals o.Keyid into g // g has all the matching orders
                 from o in g // MyOrders can only be populated if this from-clause is given
                 select new { CustomerName = c.Name, Orders = g, MyOrders = o.OrderNumber }; 

        // Identical in effect to the previous code section
        var q1 = from c in customers
                 select new {CustomerName = c.Name,
                             Orders = from o in orders
                                      where c.Keyid == o.Keyid
                                      select o
                 };

        Console.WriteLine("Group join");
        foreach (var group in q1)
        {
            Console.WriteLine("Customer: {0}", group.CustomerName);
            foreach (var order in group.Orders)
                Console.WriteLine("  - {0}", order.OrderNumber);
        }

        // Outer join
        var q2 = from c in customers
                 join o in orders on c.Keyid equals o.Keyid into g // g has all the matching orders
                 from o in g.DefaultIfEmpty()
                 //select new { CustomerName = c.Name, Orders = o == null ? "(No orders)" : o.OrderNumber };
                 select new { CustomerName = c.Name, Orders = o == null ? "(No orders)" : o.OrderNumber};

        foreach (var group in q2)
        {
            Console.WriteLine("Customer: {0}, Order: {1}", group.CustomerName, group.Orders);
        }

        // Group by
        string[] words3 = { "blueberry", "chimpanzee", "abacus", "banana", "apple", "cheese" };

        var wordGroups =
            from w in words3
            orderby w
            group w by w[0] into g // Group by the first char
            select new { FirstLetter = g.Key, Words = g };

        Console.WriteLine("Group by");
        foreach (var g in wordGroups)
        {
            Console.WriteLine("Words that start with the letter '{0}':", g.FirstLetter);
            foreach (var w in g.Words)
            {
                Console.WriteLine(w);
            }
        } 

        // Element operators
        var myorders = (from o in orders where o.Keyid == 1 select o).First(); // there are more than one orders with Key=1

        Console.WriteLine("Order key: {0}, order number: {1}", myorders.Keyid, myorders.OrderNumber);

        int[] numbers3 = { };
        int firstNumOrDefault = numbers3.FirstOrDefault();
        Console.WriteLine(firstNumOrDefault);

        var myorders2 = (from o in orders where o.Keyid > 1 select o).ElementAt(3); // Get the fourth returned row as it starts at 0
        Console.WriteLine("Order key: {0}, order number: {1}", myorders2.Keyid, myorders2.OrderNumber);

        // Quantifiers
        string[] words5 = { "believe", "relief", "receipt", "field" };

        bool iAfterE = words5.Any(w => w.Contains("ei"));
        Console.WriteLine("There is a word that contains in the list that contains 'ei': {0}", iAfterE); 

        // Aggregation
        int[] factorsOf3002 = { 2, 2, 3, 5, 5 };
        int uniqueFactors2 = factorsOf3002.Distinct().Count();

        Console.WriteLine("There are {0} unique factors of 300.", uniqueFactors2);

        int[] numbers4 = { 5, 4, 1, 3, 9, 8, 6, 7, 2, 0 };
        int oddNumbers = numbers4.Count(n => n % 2 == 1);

        Console.WriteLine("There are {0} odd numbers in the list.", oddNumbers);

        var q3 = from c in customers
                 join o in orders on c.Keyid equals o.Keyid into g1 // g has all the matching orders
                 group g1 by c.Name into g12
                 select new { CustomerName = g12.Key, Orders = g12 };

        Console.WriteLine("My weird example");
        foreach (var group in q3)
        {
            foreach (var ord in group.Orders)
            {
                Console.WriteLine("Customer: {0}, # of orders: {1}", group.CustomerName, ord.Count());
            }
        }

        var q4 = from c in customers
                 join o in orders on c.Keyid equals o.Keyid into g1 // g has all the matching orders
                 select new { CustomerName = c.Name, Orders = g1.Count() };

        foreach (var cust in q4)
        {
            Console.WriteLine("Customer: {0}, # of orders: {1}", cust.CustomerName, cust.Orders);
        }

        var q5 = from c in customers
                 join o in orders on c.Keyid equals o.Keyid into j1
                 from j2 in j1.DefaultIfEmpty()
                 group j2 by c.Name into grouped
                 select new { CustomerName = grouped.Key, Orders = grouped.Count(t => t != null) }; // Null test needed as it is an outer join

        foreach (var q51 in q5)
        {
            Console.WriteLine("Customer: {0}, # of orders: {1}", q51.CustomerName, q51.Orders);
        }

        int[] numbers6 = { 5, 4, 1, 3, 9, 8, 6, 7, 2, 0 };      
        double numSum = numbers6.Sum();

        Console.WriteLine("The sum of the numbers is {0}.", numSum);

        string[] words4 = { "cherry", "apple", "blueberry" };   
        double totalChars = words4.Sum(w => w.Length);

        Console.WriteLine("There are a total of {0} characters in these words.", totalChars);

        var q6 = from c in customers
                 join o in orders on c.Keyid equals o.Keyid into j1
                 from j2 in j1.DefaultIfEmpty()
                 group j2 by c.Name into grouped
                 select new { CustomerName = grouped.Key, Orders = grouped.Sum(j2 => j2 == null ? 0 : j2.Amount) }; // Null test needed as it is an outer join

        foreach (var q61 in q6)
        {
            Console.WriteLine("Customer: {0}, total amount: {1}", q61.CustomerName, q61.Orders);
        }

        var q7 = from c in customers
                 join o in orders on c.Keyid equals o.Keyid into j1
                 from j2 in j1.DefaultIfEmpty() // Outer join that sets order to null
                 group j2 by c.Name into grouped
                 from p1 in grouped
                 where p1 != null // Because of the outer join that sets order to null later the access of Amount throws exception
                 let maxOrder = grouped.Max(p => p.Amount) // Find max value in each group
                 select new { CustomerName = grouped.Key, Orders = grouped.Where(j2 => j2.Amount == maxOrder) }; // Pick order with max amount only

        Console.WriteLine("Last try:");
        foreach (var q71 in q7)
        {
            foreach (var thisorder in q71.Orders)
            {
                Console.WriteLine("Customer: {0}, Max order amount: {1}", q71.CustomerName, thisorder.Amount );
            }
        }

        // Miscellaneous operators
        var wordsA = new string[] { "cherry", "apple", "blueberry" };
        var wordsB = new string[] { "cherry", "apple", "blueberry" };

        bool match = wordsA.SequenceEqual(wordsB);

        Console.WriteLine("The sequences match: {0}", match); 

        Console.ReadKey();
    }
}

public class CaseInsensitiveComparer : IComparer<string>
{
    public int Compare(string x, string y)
    {
        return string.Compare(x, y, StringComparison.OrdinalIgnoreCase);
    }
}

public class Table1
{
    public int entity_id;
    public int premise_id;
    public string name;

    public Table1 (int entity_id, int premise_id, string name)
    {
        this.entity_id = entity_id;
        this.premise_id = premise_id;
        this.name = name;
    }
}

public class Table2
{
    public int premise_id;
    public string address;

    public Table2 (int premise_id, string address)
    {
        this.premise_id = premise_id;
        this.address = address;
    }
}

public class Customer
{
    public int Keyid;
    public string Name;
}

public class Order
{
    public int Keyid;
    public string OrderNumber;
    public int Amount;
}

class ThreadExample1
{
    private static int sharedRes = 0;

    static void Main3()
    {
        ThreadStart threadWork = new ThreadStart(doSomeWork);
        Thread thread = new Thread(threadWork);
        thread.Start();

        for (int i = 0; i < 10; i++)
        {
            sharedRes++;
            Console.WriteLine("Main Method Loop: {0}, value: {1}", i.ToString(), sharedRes);

            // Delay so we can visibly see the work being done
            Thread.Sleep(500);
        }

        Console.ReadKey();
    }

    protected static void doSomeWork()
    {
        for (int i = 0; i < 10; i++)
        {
            sharedRes++;
            Console.WriteLine("doSomeWork Loop: {0}, value: {1}", i.ToString(), sharedRes);

            // A different delay so we can see difference
            Thread.Sleep(500);
        }
    }
}

public class RegexSample
{
    static string _validEmailAddress = "somebody@somedomain.com";
    static string _invalidEmailAddress = "invalid.email-address.com&somedomann..3com";
    static string emailRegex = @"^[\w-]+(\.[\w-]+)*@([a-z0-9-]+(\.[a-z0-9-]+)*?\.[a-z]{2,6}|(\d{1,3}\.){3}\d{1,3})(:\d{4})?$";
    private static string testexpr = "CSACsi and Vila 4ever";
    private static string testRegex = @"[A-Z]{2,3}";

    private static string testexpr3 = "CSAcsi and Vila 4ever";
    private static string testRegex3 = @"C.*?"; // Non-greedy version of *
    private static string testexpr1 = "CSacsi and Vila 4ever";
    private static string testRegex1 = @"[A-Z]{1}[a-z]+\s+(an)+.*[1-5]+"; // One uppercase letter followed by lowercase letters followed by space followed by "an" followed by a number (one or more times)
    private static string testexpr2 = "Csacsi and Vila 4ever";
    private static string testRegex2 = @"[a-z]+\s+(an)+.*[1-5]+"; // Lowercase letters followed by space followed by "an" followed by a number (one or more times)

    public static void Main(String[] args)
    {
        Regex regularExpression = new Regex(emailRegex);

        if (regularExpression.IsMatch(_validEmailAddress))
            Console.WriteLine("{0}: is Valid Email Address", _validEmailAddress);
        else
            Console.WriteLine("{0}: is NOT a Valid Email Address", _validEmailAddress);

        if (regularExpression.IsMatch(_invalidEmailAddress))
            Console.WriteLine("{0}: is Valid Email Address", _invalidEmailAddress);
        else
            Console.WriteLine("{0}: is NOT a Valid Email Address", _invalidEmailAddress);

        Regex regexp = new Regex(testRegex);
        if (regexp.IsMatch(testexpr))
            Console.WriteLine("Matched here: {0}", regexp.Match(testexpr));
        else
            Console.WriteLine("No match");

        Console.ReadKey();
    }
}

public class MonitorSample
{
    public static void Main5(String[] args)
    {
        Beer bottle = new Beer();

        Brewer brewer = new Brewer(bottle, 20);
        Drinker drinker = new Drinker(bottle, 20); 

        Thread brewerThread = new Thread(new ThreadStart(brewer.ThreadRun));
        Thread drinkerThread = new Thread(new ThreadStart(drinker.ThreadRun));

        try
        {
            brewerThread.Start(); // Start both
            drinkerThread.Start();

            brewerThread.Join();   // Join both threads with no timeout
            drinkerThread.Join();
        }
        catch (ThreadStateException e)
        {
            Console.WriteLine(e);  // Display text of exception
        }
        catch (ThreadInterruptedException e)
        {
            Console.WriteLine(e);
        }
        Console.WriteLine("Both the brewer and the drinker threads are completed. Press any key.");
        Console.ReadKey();
    }
}

public class Beer
{
    private int thebeer = 0; // The bottle itself. 1 if exists i.e. brewed one, 0 if not
    public int bottlesBrewed = 0; // Number of bottles brewed overall
    public int bottlesDrunk = 0; // Number of bottles drunk overall

    public void drink()
    {
        lock (this) // Enter synchronization block
        {
            if (thebeer == 0) // Always starts here, so it has to wait for a bottle to be brewed first
            {
                try
                {
                    Monitor.Wait(this);
                }
                catch (SynchronizationLockException e)
                {
                    Console.WriteLine(e);
                }
                catch (ThreadInterruptedException e)
                {
                    Console.WriteLine(e);
                }
            }
            clearBeer(); // Drink a bottle
            bottlesDrunk ++;
            Console.WriteLine("Drinking bottle number: {0}", bottlesDrunk);
            Monitor.Pulse(this); // Send a signal to another thread waiting on the lock. It is the brewer that can produce another bottle
        } // Exit synchronization block
    }

    public void brew()
    {
        lock (this) // Enter synchronization block
        {
            if (thebeer == 1) // If this is set that means a bottle is already brewed so wait until it is drunk
            {
                try
                {
                    Monitor.Wait(this); // Wait for drinker
                }
                catch (SynchronizationLockException e)
                {
                    Console.WriteLine(e);
                }
                catch (ThreadInterruptedException e)
                {
                    Console.WriteLine(e);
                }
            }
            setBeer(); // Brew a bottle
            bottlesBrewed++; 
            Console.WriteLine("Producing bottle number: {0}", bottlesBrewed);
            Monitor.Pulse(this); // Signal that a bottle is ready if drinker is waiting for the lock to be released
        } // Exit synchronization block
    }

    private void setBeer()
    {
        if (thebeer == 1)
        {
            // This can not happen
            Console.WriteLine("Problem: there is already a bottle brewed!");
        }
        else
        {
            thebeer = 1;            
        }
    }

    private void clearBeer()
    {
        if (thebeer == 0)
        {
            // This can not happen
            Console.WriteLine("Problem: there is no bottle ready to be drunk!");
        }
        thebeer = 0;
    }
}

public class Brewer
{
    private Beer thisBottle;
    private int brewLimit;

    public Brewer(Beer thisbottle, int brewlimit)
    {
        this.thisBottle = thisbottle;
        this.brewLimit = brewlimit;
    }

    public void ThreadRun( )
    {
        while (thisBottle.bottlesBrewed < brewLimit)
        {
            thisBottle.brew();
        }
    }
}

public class Drinker
{
    private Beer thisBottle;
    private int drinkLimit;

    public Drinker(Beer thisbottle, int drinklimit)
    {
        this.thisBottle = thisbottle;
        this.drinkLimit = drinklimit;
    }

    public void ThreadRun()
    {
        while (thisBottle.bottlesDrunk < drinkLimit)
        {
            thisBottle.drink();
        }
    }
}

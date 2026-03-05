using System.Collections.Generic;
using System.Collections.ObjectModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class EmptyArray<T>
        {
        public static readonly T[]      Array = new T[0];
        public static readonly IList<T> List  = new ReadOnlyCollection<T>(new T[0]);
        }
    }
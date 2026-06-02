using System;
using System.Collections.Generic;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlObjectCollectionChanges<T> : IList<T>,IDisposable
        {
        }
    }
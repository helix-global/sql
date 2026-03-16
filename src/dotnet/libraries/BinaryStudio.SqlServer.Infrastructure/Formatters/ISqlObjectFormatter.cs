using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlObjectFormatter<T>
        {
        void WriteTo(T source,out String target);
        }
    }

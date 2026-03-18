using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlObjectFormatter<T>
        {
        void WriteTo(IServiceProvider provider,T source,out String target);
        }
    }

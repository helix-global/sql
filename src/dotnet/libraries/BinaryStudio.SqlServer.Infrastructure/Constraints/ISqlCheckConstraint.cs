using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlCheckConstraint : ISqlConstraint
        {
        String Expression { get; }
        }
    }
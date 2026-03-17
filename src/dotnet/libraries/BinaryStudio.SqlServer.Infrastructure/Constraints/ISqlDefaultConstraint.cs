using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlDefaultConstraint : ISqlConstraint
        {
        String Expression { get; }
        }
    }
using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlColumnIdentity : ISqlConstraint
        {
        Int32? Increment { get; }
        Int32? Seed { get; }
        }
    }

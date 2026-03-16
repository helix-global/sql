using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlConstraint
        {
        SqlIdentifier Name { get; }
        SqlConstraintType Type { get; }
        String ToString(ISqlCase Case);
        }
    }
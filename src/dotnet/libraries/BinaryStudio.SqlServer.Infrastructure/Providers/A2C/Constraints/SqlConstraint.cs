using System;

namespace BinaryStudio.SqlServer.Infrastructure.A2C
    {
    internal class SqlConstraint : ISqlConstraint
        {
            public SqlIdentifier Name { get; }
            public SqlConstraintType Type { get; }
            public String ToString(ISqlCase Case)
            {
                throw new NotImplementedException();
            }
        }
    }
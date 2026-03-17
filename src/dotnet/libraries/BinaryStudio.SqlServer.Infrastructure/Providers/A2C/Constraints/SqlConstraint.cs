using System;
using System.Collections.Generic;

namespace BinaryStudio.SqlServer.Infrastructure.A2C
    {
    internal class SqlConstraint : ISqlConstraint
        {
            public SqlIdentifier Name { get; }
            public SqlConstraintType Type { get; }
            public IList<ISqlIndexOption> IndexOptions { get; }

            public string ToString(ISqlObjectFormatter<ISqlConstraint> Formatter)
            {
            throw new NotImplementedException();
            }
        }
    }
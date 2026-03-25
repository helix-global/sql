using System;
using System.Collections.Generic;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure
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
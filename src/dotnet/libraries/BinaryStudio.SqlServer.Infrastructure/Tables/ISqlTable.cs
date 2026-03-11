using System;
using System.Collections.Generic;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlTable
        {
        SqlObjectIdentifier QualifiedName { get; }
        Boolean IsAnsiNullsOn { get; }
        Boolean IsLargeValueTypesOutOfRow { get; }
        Boolean IsTableLockOnBulkLoad { get; }
        Int32 TextInRowSize { get; }
        SqlLockEscalationMethod LockEscalation { get; }
        IList<ISqlColumn> Columns { get; }
        IList<ISqlConstraint> Constraints { get; }
        }
    }
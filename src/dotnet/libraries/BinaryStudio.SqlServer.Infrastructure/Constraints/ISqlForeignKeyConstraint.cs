using System.Collections.Generic;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlForeignKeyConstraint : ISqlConstraint
        {
        IList<SqlIdentifier> Columns { get; }
        IList<SqlIdentifier> ReferencedColumns { get; }
        SqlObjectIdentifier ReferencedTable { get; }
        SqlForeignKeyAction DeleteAction { get; }
        SqlForeignKeyAction UpdateAction { get; }
        }
    }
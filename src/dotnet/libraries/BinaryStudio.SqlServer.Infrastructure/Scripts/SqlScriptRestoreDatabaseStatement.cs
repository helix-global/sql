using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlRestoreDatabaseStatement))]
    internal sealed class SqlScriptRestoreDatabaseStatement : SqlScriptBackupRestoreDatabaseStatement<SqlRestoreDatabaseStatement>
        {
        #region ctor{IServiceProvider,SqlRestoreDatabaseStatement}
        public SqlScriptRestoreDatabaseStatement(IServiceProvider context,SqlRestoreDatabaseStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
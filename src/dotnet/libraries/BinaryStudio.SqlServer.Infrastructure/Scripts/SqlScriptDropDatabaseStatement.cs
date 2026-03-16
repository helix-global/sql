using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlDropDatabaseStatement))]
    internal sealed class SqlScriptDropDatabaseStatement : SqlScriptDropStatement<SqlDropDatabaseStatement>
        {
        #region ctor{IServiceProvider,SqlDropDatabaseStatement}
        public SqlScriptDropDatabaseStatement(IServiceProvider context,SqlDropDatabaseStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
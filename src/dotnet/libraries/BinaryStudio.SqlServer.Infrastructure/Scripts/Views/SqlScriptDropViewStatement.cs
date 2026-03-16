using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlDropViewStatement))]
    internal sealed class SqlScriptDropViewStatement : SqlScriptDropStatement<SqlDropViewStatement>
        {
        #region ctor{IServiceProvider,SqlDropViewStatement}
        public SqlScriptDropViewStatement(IServiceProvider context,SqlDropViewStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
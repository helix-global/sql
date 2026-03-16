using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlDropLoginStatement))]
    internal sealed class SqlScriptDropLoginStatement : SqlScriptDropStatement<SqlDropLoginStatement>
        {
        #region ctor{IServiceProvider,SqlDropLoginStatement}
        public SqlScriptDropLoginStatement(IServiceProvider context,SqlDropLoginStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
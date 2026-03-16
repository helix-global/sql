using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlUseStatement))]
    internal sealed class SqlScriptUseStatement : SqlScriptStatement<SqlUseStatement>
        {
        #region ctor{IServiceProvider,SqlUseStatement}
        public SqlScriptUseStatement(IServiceProvider context,SqlUseStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
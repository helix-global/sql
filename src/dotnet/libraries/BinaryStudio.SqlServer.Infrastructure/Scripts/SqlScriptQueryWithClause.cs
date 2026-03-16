using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlQueryWithClause))]
    internal sealed class SqlScriptQueryWithClause : SqlScriptCodeObject<SqlQueryWithClause>
        {
        #region ctor{IServiceProvider,SqlQueryWithClause}
        public SqlScriptQueryWithClause(IServiceProvider context,SqlQueryWithClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
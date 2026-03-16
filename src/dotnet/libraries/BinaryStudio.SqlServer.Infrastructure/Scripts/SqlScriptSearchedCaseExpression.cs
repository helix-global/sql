using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlSearchedCaseExpression))]
    internal sealed class SqlScriptSearchedCaseExpression : SqlScriptCaseExpression<SqlSearchedCaseExpression>
        {
        #region ctor{IServiceProvider,SqlSearchedCaseExpression}
        public SqlScriptSearchedCaseExpression(IServiceProvider context,SqlSearchedCaseExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlPivotTableExpression))]
    internal sealed class SqlScriptPivotTableExpression : SqlScriptTableExpression<SqlPivotTableExpression>
        {
        #region ctor{IServiceProvider,SqlPivotTableExpression}
        public SqlScriptPivotTableExpression(IServiceProvider context,SqlPivotTableExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
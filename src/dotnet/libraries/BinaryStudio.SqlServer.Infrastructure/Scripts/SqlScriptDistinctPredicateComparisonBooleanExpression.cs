using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlDistinctPredicateComparisonBooleanExpression))]
    internal sealed class SqlScriptDistinctPredicateComparisonBooleanExpression : SqlScriptBooleanExpression<SqlDistinctPredicateComparisonBooleanExpression>
        {
        #region ctor{IServiceProvider,SqlDistinctPredicateComparisonBooleanExpression}
        public SqlScriptDistinctPredicateComparisonBooleanExpression(IServiceProvider context,SqlDistinctPredicateComparisonBooleanExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
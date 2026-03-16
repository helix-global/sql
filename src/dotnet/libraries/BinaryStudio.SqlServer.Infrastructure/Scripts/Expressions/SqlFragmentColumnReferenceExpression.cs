using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(ColumnReferenceExpression))]
    internal sealed class SqlFragmentColumnReferenceExpression : SqlFragmentPrimaryExpression<ColumnReferenceExpression>
        {
        #region ctor{IServiceProvider,ColumnReferenceExpression}
        public SqlFragmentColumnReferenceExpression(IServiceProvider context,ColumnReferenceExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
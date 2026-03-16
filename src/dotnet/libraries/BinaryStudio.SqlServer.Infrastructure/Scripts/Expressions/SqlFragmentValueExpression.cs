using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlFragmentValueExpression<T> : SqlFragmentPrimaryExpression<T>
        where T: ValueExpression
        {
        #region ctor{IServiceProvider,T}
        public SqlFragmentValueExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
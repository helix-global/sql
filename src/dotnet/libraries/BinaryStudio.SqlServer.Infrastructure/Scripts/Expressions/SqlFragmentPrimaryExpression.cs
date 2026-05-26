using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlFragmentPrimaryExpression<T> : SqlFragmentScalarExpression<T>
        where T: PrimaryExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlFragmentPrimaryExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
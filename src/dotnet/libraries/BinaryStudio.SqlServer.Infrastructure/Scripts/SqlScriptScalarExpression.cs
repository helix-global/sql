using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptScalarExpression<T> : SqlScriptCodeObject<T>,ISqlScriptScalarExpression
        where T : SqlScalarExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptScalarExpression(IServiceProvider context,T source)
            : base(context, source)
            {
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Script;
            }
        #endregion
        }
    }
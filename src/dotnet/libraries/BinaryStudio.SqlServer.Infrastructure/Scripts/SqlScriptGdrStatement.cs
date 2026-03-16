using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptGdrStatement<T> : SqlScriptStatement<T>
        where T : SqlGdrStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptGdrStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
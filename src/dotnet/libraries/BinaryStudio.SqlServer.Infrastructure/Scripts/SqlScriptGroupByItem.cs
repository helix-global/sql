using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptGroupByItem<T> : SqlScriptCodeObject<T>
        where T : SqlGroupByItem
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptGroupByItem(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }